// SPDX-License-Identifier: GPL-2.0
/*
 * /init wrapper for booting Android on redwood 6.18 with nothing shared
 * written. Built with the kernel's nolibc.
 *
 * PID 1 execs Android's first stage init (/init.android) straight away. A
 * child, in a mount namespace of its own so first stage init never sees its
 * mounts, waits for init to mount /vendor and binds the fstab in /fstab.img over
 * /vendor/etc/fstab.default in init's namespace: /data on tmpfs, metadata,
 * persist and qmcs read-only. If that fails it reboots to the bootloader
 * before second stage init can mount anything.
 *
 * The kernel log goes to logdump through bootlog.ko: a userspace logger
 * here loses kmsg and the partition as soon as init loads its SELinux policy.
 */
#include "nolibc.h"
#include <linux/reboot.h>
#include <linux/sched.h>
#include <linux/loop.h>

#define SRC_IMG		"/fstab.img"
#define LOOP_DIR	"/dev/.ls618"
#define DST_FSTAB	"/vendor/etc/fstab.default"

static int kw = -1;

struct linux_dirent64_ {
	unsigned long long d_ino;
	long long d_off;
	unsigned short d_reclen;
	unsigned char d_type;
	char d_name[];
};

static void sync(void)
{
	my_syscall0(__NR_sync);
}

static void klog(const char *fmt, ...)
{
	char b[512];
	va_list ap;
	int n = snprintf(b, sizeof(b), "<3>logsaver618: ");

	va_start(ap, fmt);
	n += vsnprintf(b + n, sizeof(b) - n, fmt, ap);
	va_end(ap);
	if (kw >= 0)
		write(kw, b, n < (int)sizeof(b) ? n : (int)sizeof(b) - 1);
}

static long ls_unshare(int f) { return my_syscall1(__NR_unshare, f); }
static long ls_setns(int fd, int t) { return my_syscall2(__NR_setns, fd, t); }
static long ls_chroot(const char *p) { return my_syscall1(__NR_chroot, p); }
static long ls_fchdir(int fd) { return my_syscall1(__NR_fchdir, fd); }

/* ---------- the test fstab ---------- */

static int imgfd = -1;

static void to_bootloader(const char *why)
{
	klog("%s, rebooting to the bootloader\n", why);
	sync();
	my_syscall4(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
		    LINUX_REBOOT_CMD_RESTART2, "bootloader");
}

/* 0: not yet (no /vendor in init's root), 1: placed */
static int place_fstab(void)
{
	pid_t pid;
	int st = 0;

	if (access("/ls/proc/1/root" DST_FSTAB, F_OK))
		return 0;
	pid = fork();
	if (pid == 0) {
		int ns = open("/ls/proc/1/ns/mnt", O_RDONLY);
		int root = open("/ls/proc/1/root", O_RDONLY | O_DIRECTORY);
		struct loop_config lc;
		char ldev[64];
		int ctl, lfd, n;

		if (ns < 0 || root < 0 || ls_setns(ns, CLONE_NEWNS) || ls_fchdir(root) ||
		    ls_chroot("."))
			exit(2);
		/*
		 * The test fstab sits in a small ext4 image whose file carries
		 * vendor_configs_file in its security.selinux xattr: ext4 keeps
		 * that label through the policy load, so vold and the boot
		 * control HAL can read it like the vendor's own fstab.
		 */
		mknod(LOOP_DIR "-ctl", S_IFCHR | 0600, makedev(10, 237));
		ctl = open(LOOP_DIR "-ctl", O_RDWR);
		n = ctl >= 0 ? ioctl(ctl, LOOP_CTL_GET_FREE, 0) : -1;
		if (n < 0)
			exit(3);
		snprintf(ldev, sizeof(ldev), LOOP_DIR "-loop%d", n);
		mknod(ldev, S_IFBLK | 0600, makedev(7, n));
		lfd = open(ldev, O_RDONLY);
		memset(&lc, 0, sizeof(lc));
		lc.fd = imgfd;
		lc.info.lo_flags = LO_FLAGS_READ_ONLY;
		if (lfd < 0 || ioctl(lfd, LOOP_CONFIGURE, &lc))
			exit(5);
		mkdir(LOOP_DIR, 0755);
		if (mount(ldev, LOOP_DIR, "ext4", MS_RDONLY | MS_NOSUID | MS_NODEV | MS_NOEXEC, "noload"))
			exit(6);
		if (mount(LOOP_DIR "/fstab.default", DST_FSTAB, NULL, MS_BIND, NULL))
			exit(4);
		/*
		 * Optional: a system_ext build.prop with adb on, for test boots
		 * (system_ext is mounted before vendor, and init only reads the
		 * properties in second stage). Not fatal if it fails.
		 */
		if (!access(LOOP_DIR "/system_ext.build.prop", F_OK)) {
			if (mount(LOOP_DIR "/system_ext.build.prop", "/system_ext/etc/build.prop",
				  NULL, MS_BIND, NULL))
				klog("binding the test system_ext build.prop failed: %d\n", errno);
			else
				klog("test system_ext build.prop bound: adb on\n");
		}
		exit(0);
	}
	if (pid < 0)
		return 0;
	waitpid(pid, &st, 0);
	if (!WIFEXITED(st) || WEXITSTATUS(st)) {
		klog("binding the test fstab failed: %d\n", WIFEXITED(st) ? WEXITSTATUS(st) : -1);
		to_bootloader("no tmpfs /data fstab");
		return 1;
	}
	klog("test fstab from %s bound over %s: /data on tmpfs\n", SRC_IMG, DST_FSTAB);
	return 1;
}

static void saver(void)
{
	struct timespec ts = { 0, 1000 * 1000 };
	int placed = 0, i;

	setsid();
	ls_unshare(CLONE_NEWNS);
	mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL);
	mkdir("/ls", 0700);
	mkdir("/ls/proc", 0700);
	mount("proc", "/ls/proc", "proc", 0, NULL);
	mknod("/ls/kmsg", S_IFCHR | 0600, makedev(1, 11));
	kw = open("/ls/kmsg", O_WRONLY);

	imgfd = open(SRC_IMG, O_RDONLY);
	if (imgfd < 0)
		to_bootloader("no " SRC_IMG " in the ramdisk");
	klog("started\n");

	/*
	 * /vendor is only up for about 100 ms before init loads the SELinux
	 * policy, after which this process can't touch init's mounts: watch
	 * for it every millisecond and do nothing else meanwhile.
	 */
	for (i = 0; !placed && i < 60000; i++) {
		placed = place_fstab();
		if (!placed)
			my_syscall2(__NR_nanosleep, &ts, NULL);
	}
	if (!placed)
		to_bootloader("init never mounted /vendor");
	for (;;)
		sleep(3600);
}

int main(int argc, char **argv, char **envp)
{
	(void)argc;
	if (fork() == 0) {
		saver();
		exit(0);
	}
	execve("/init.android", argv, envp);
	return 127;
}
