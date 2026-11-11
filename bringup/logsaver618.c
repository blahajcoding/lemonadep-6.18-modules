// SPDX-License-Identifier: GPL-2.0
/*
 * /init wrapper for booting Android on redwood 6.18 with nothing shared
 * written. Built with the kernel's nolibc.
 *
 * PID 1 execs Android's first stage init (/init.android) straight away. A
 * child, in a mount namespace of its own so first stage init never sees its
 * mounts:
 * - writes the kernel log (which carries init's messages too) to the logdump
 *   partition holding the older log, every 2 s, in the bring-up shell's
 *   format (REDWOOD618LOG seq=N), so the shell can read it after a reboot;
 * - once init has /vendor mounted, bind mounts /fstab.test over
 *   /vendor/etc/fstab.default in init's namespace: /data on tmpfs and
 *   metadata, persist and qmcs read-only. If that fails it reboots to the
 *   bootloader before second stage init can mount anything.
 */
#include "nolibc.h"
#include <linux/reboot.h>
#include <linux/sched.h>

#define SRC_FSTAB	"/fstab.test"
#define DST_FSTAB	"/vendor/etc/fstab.default"
#define LOG_MAX		(8 << 20)

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
static long ls_pwrite(int fd, const void *b, size_t n, long off)
{
	return my_syscall4(__NR_pwrite64, fd, b, n, off);
}

static char *slurp(const char *path, size_t *lenp)
{
	static char b[1 << 16];
	int fd = open(path, O_RDONLY);
	ssize_t n;

	if (fd < 0)
		return NULL;
	n = read(fd, b, sizeof(b) - 1);
	close(fd);
	if (n < 0)
		return NULL;
	b[n] = 0;
	if (lenp)
		*lenp = n;
	return b;
}

/* ---------- logdump ---------- */

static char devs[4][64];
static int ndevs;

static void find_logdumps(void)
{
	char dents[16384], path[256];
	int d = open("/ls/sys/class/block", O_RDONLY | O_DIRECTORY);
	long n;

	ndevs = 0;
	if (d < 0)
		return;
	while ((n = my_syscall3(__NR_getdents64, d, dents, sizeof(dents))) > 0) {
		long off = 0;

		while (off < n && ndevs < 4) {
			struct linux_dirent64_ *e = (void *)(dents + off);
			char *t, *colon;
			int maj;

			off += e->d_reclen;
			if (e->d_name[0] == '.')
				continue;
			snprintf(path, sizeof(path), "/ls/sys/class/block/%s/uevent", e->d_name);
			t = slurp(path, NULL);
			if (!t || !strstr(t, "PARTNAME=logdump\n"))
				continue;
			snprintf(path, sizeof(path), "/ls/sys/class/block/%s/dev", e->d_name);
			t = slurp(path, NULL);
			if (!t || !(colon = strchr(t, ':')))
				continue;
			*colon = 0;
			maj = atoi(t);
			snprintf(devs[ndevs], sizeof(devs[0]), "/ls/%s", e->d_name);
			unlink(devs[ndevs]);
			mknod(devs[ndevs], S_IFBLK | 0600, makedev(maj, atoi(colon + 1)));
			ndevs++;
		}
	}
	close(d);
}

static char logdev[64];
static unsigned int logseq;

static int pick_logdev(void)
{
	unsigned int best = ~0u, top = 0;
	char hdr[64];
	int i;

	find_logdumps();
	if (!ndevs)
		return -1;
	for (i = 0; i < ndevs; i++) {
		unsigned int seq = 0;
		int fd = open(devs[i], O_RDONLY);

		memset(hdr, 0, sizeof(hdr));
		if (fd >= 0) {
			read(fd, hdr, sizeof(hdr) - 1);
			close(fd);
		}
		if (!strncmp(hdr, "REDWOOD618LOG seq=", 18))
			seq = strtoul(hdr + 18, NULL, 10);
		if (seq > top)
			top = seq;
		if (seq < best) {
			best = seq;
			snprintf(logdev, sizeof(logdev), "%s", devs[i]);
		}
	}
	logseq = top + 1;
	klog("logdump: writing %s as boot %u (android)\n", logdev, logseq);
	return 0;
}

static char logbuf[LOG_MAX];

static void save_log(void)
{
	int k, out;
	size_t used;
	char rec[8192];

	if (!logdev[0] && pick_logdev())
		return;
	used = snprintf(logbuf, sizeof(logbuf), "REDWOOD618LOG seq=%08u android\n", logseq);
	k = open("/ls/kmsg", O_RDONLY | O_NONBLOCK);
	if (k < 0)
		return;
	for (;;) {
		ssize_t n = read(k, rec, sizeof(rec) - 1);
		char *msg, *f1, *f2, *e;
		long long us;

		if (n < 0) {
			if (errno == EPIPE)
				continue;
			break;
		}
		rec[n] = 0;
		msg = strchr(rec, ';');
		f1 = strchr(rec, ',');
		f2 = f1 ? strchr(f1 + 1, ',') : NULL;
		if (!msg)
			continue;
		e = strchr(msg, '\n');
		if (e)
			e[1] = 0;
		us = f2 ? strtoll(f2 + 1, NULL, 10) : 0;
		if (used + 32 + strlen(msg) >= sizeof(logbuf) - 1)
			break;
		used += snprintf(logbuf + used, sizeof(logbuf) - used, "[%5lld.%06lld] %s",
				 us / 1000000, us % 1000000, msg + 1);
	}
	close(k);
	logbuf[used++] = 0;
	out = open(logdev, O_WRONLY);
	if (out < 0)
		return;
	ls_pwrite(out, logbuf, used, 0);
	fsync(out);
	close(out);
}

/* ---------- the test fstab ---------- */

static char fstab[65536];
static size_t fstab_len;

static void to_bootloader(const char *why)
{
	klog("%s, rebooting to the bootloader\n", why);
	save_log();
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
		int out;

		if (ns < 0 || root < 0 || ls_setns(ns, CLONE_NEWNS) || ls_fchdir(root) ||
		    ls_chroot("."))
			exit(2);
		out = open("/dev/.fstab.test618", O_WRONLY | O_CREAT | O_TRUNC, 0644);
		if (out < 0 || write(out, fstab, fstab_len) != (ssize_t)fstab_len)
			exit(3);
		close(out);
		if (mount("/dev/.fstab.test618", DST_FSTAB, NULL, MS_BIND, NULL))
			exit(4);
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
	klog("%s bound over %s: /data on tmpfs\n", SRC_FSTAB, DST_FSTAB);
	return 1;
}

static void saver(void)
{
	struct timespec ts = { 0, 10 * 1000 * 1000 };
	int placed = 0, i, fd;

	setsid();
	ls_unshare(CLONE_NEWNS);
	mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL);
	mkdir("/ls", 0700);
	mkdir("/ls/sys", 0700);
	mount("sysfs", "/ls/sys", "sysfs", 0, NULL);
	mkdir("/ls/proc", 0700);
	mount("proc", "/ls/proc", "proc", 0, NULL);
	mknod("/ls/kmsg", S_IFCHR | 0600, makedev(1, 11));
	kw = open("/ls/kmsg", O_WRONLY);

	fd = open(SRC_FSTAB, O_RDONLY);
	if (fd >= 0) {
		ssize_t n = read(fd, fstab, sizeof(fstab) - 1);

		fstab_len = n > 0 ? n : 0;
		close(fd);
	}
	if (!fstab_len)
		to_bootloader("no " SRC_FSTAB " in the ramdisk");
	klog("started, test fstab %u bytes\n", (unsigned int)fstab_len);

	/* poll fast until the fstab is in place, then save the log every 2 s */
	for (i = 0; !placed && i < 6000; i++) {
		placed = place_fstab();
		if (i % 200 == 0)
			save_log();
		my_syscall2(__NR_nanosleep, &ts, NULL);
	}
	if (!placed)
		to_bootloader("init never mounted /vendor");
	for (i = 0;; i++) {
		save_log();
		if (i % 30 == 0)
			klog("tick %d\n", i);
		sleep(2);
	}
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
