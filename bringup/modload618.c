// SPDX-License-Identifier: GPL-2.0
/*
 * Bring-up init for 6.18 on redwood, built with the kernel's nolibc. Loads
 * the first stage modules the way Android's init does, dependencies first
 * from modules.dep, saves the kernel log to the empty logdump partition and
 * goes back to the bootloader. It never touches /data or any other partition.
 */
#include "nolibc.h"
#include <linux/reboot.h>

#define MAX_MODS 1024

static void sync(void)
{
	my_syscall0(__NR_sync);
}

static void pause(void)
{
	sleep(3600);
}

static char dir[256];
static struct mod {
	char *name;
	char *deps;
	int state;	/* 0 not tried, 1 loading, 2 loaded, 3 failed */
} mods[MAX_MODS];
static int nmods, nok, nbad;

static void klog(const char *fmt, ...)
{
	char buf[512];
	va_list ap;
	int fd, n = snprintf(buf, sizeof(buf), "<6>modload: ");

	va_start(ap, fmt);
	n += vsnprintf(buf + n, sizeof(buf) - n, fmt, ap);
	va_end(ap);
	if (n >= (int)sizeof(buf))
		n = sizeof(buf) - 1;
	fd = open("/dev/kmsg", O_WRONLY);
	if (fd >= 0) {
		write(fd, buf, n);
		close(fd);
	}
}

static char *slurp(const char *path)
{
	size_t cap = 1 << 16, len = 0;
	char *buf = malloc(cap);
	int fd = open(path, O_RDONLY);
	ssize_t n;

	if (fd < 0 || !buf)
		return NULL;
	for (;;) {
		if (len + 4096 + 1 > cap) {
			char *nb = realloc(buf, cap * 2);

			if (!nb)
				break;
			buf = nb;
			cap *= 2;
		}
		n = read(fd, buf + len, cap - len - 1);
		if (n <= 0)
			break;
		len += n;
	}
	close(fd);
	buf[len] = 0;
	return buf;
}

static void read_deps(void)
{
	char path[512], *txt, *line, *next;

	snprintf(path, sizeof(path), "%s/modules.dep", dir);
	txt = slurp(path);
	if (!txt) {
		klog("no modules.dep\n");
		return;
	}
	for (line = txt; line && *line && nmods < MAX_MODS; line = next) {
		char *colon;

		next = strchr(line, '\n');
		if (next)
			*next++ = 0;
		colon = strchr(line, ':');
		if (!colon)
			continue;
		*colon = 0;
		mods[nmods].name = line;
		mods[nmods].deps = colon + 1;
		nmods++;
	}
}

static struct mod *find(const char *name)
{
	int i;

	for (i = 0; i < nmods; i++)
		if (!strcmp(mods[i].name, name))
			return &mods[i];
	return NULL;
}

static int load(const char *name)
{
	struct mod *m = find(name);
	char path[512], *deps, *tok;
	int ret = 0, fd;

	if (!m) {
		klog("%s is not in modules.dep\n", name);
		return -1;
	}
	if (m->state == 2)
		return 0;
	if (m->state == 1 || m->state == 3)
		return -1;
	m->state = 1;

	deps = strdup(m->deps);
	for (tok = deps; tok && *tok; ) {
		char *end;

		while (*tok == ' ')
			tok++;
		if (!*tok)
			break;
		end = strchr(tok, ' ');
		if (end)
			*end = 0;
		if (load(tok))
			ret = -1;
		tok = end ? end + 1 : NULL;
	}
	free(deps);

	snprintf(path, sizeof(path), "%s/%s", dir, name);
	fd = open(path, O_RDONLY);
	if (fd < 0) {
		klog("open %s failed: %d\n", name, errno);
		ret = -1;
	} else {
		long r = my_syscall3(__NR_finit_module, fd, "", 0);

		if (r < 0 && r != -EEXIST) {
			klog("load %s failed: %ld\n", name, -r);
			ret = -1;
		}
		close(fd);
	}
	m->state = ret ? 3 : 2;
	if (ret)
		nbad++;
	else
		nok++;
	return ret;
}

static void load_list(const char *list)
{
	char path[512], *txt, *line, *next;

	snprintf(path, sizeof(path), "%s/%s", dir, list);
	txt = slurp(path);
	if (!txt) {
		klog("no %s\n", list);
		return;
	}
	for (line = txt; line && *line; line = next) {
		next = strchr(line, '\n');
		if (next)
			*next++ = 0;
		if (line[0])
			load(line);
	}
	klog("%s done: %d loaded, %d failed\n", list, nok, nbad);
}

static int read_small(const char *path, char *buf, size_t len)
{
	int fd = open(path, O_RDONLY);
	ssize_t n;

	if (fd < 0)
		return -1;
	n = read(fd, buf, len - 1);
	close(fd);
	if (n < 0)
		return -1;
	buf[n] = 0;
	return n;
}

struct linux_dirent64_ {
	unsigned long long d_ino;
	long long d_off;
	unsigned short d_reclen;
	unsigned char d_type;
	char d_name[];
};

static int find_part(const char *name, char *dev, size_t len)
{
	char dents[16384], path[512], buf[1024], want[128];
	int d = open("/sys/class/block", O_RDONLY | O_DIRECTORY);
	long n;

	if (d < 0)
		return 0;
	snprintf(want, sizeof(want), "PARTNAME=%s\n", name);
	while ((n = my_syscall3(__NR_getdents64, d, dents, sizeof(dents))) > 0) {
		long off = 0;

		while (off < n) {
			struct linux_dirent64_ *e = (void *)(dents + off);

			off += e->d_reclen;
			if (e->d_name[0] == '.')
				continue;
			snprintf(path, sizeof(path), "/sys/class/block/%s/uevent", e->d_name);
			if (read_small(path, buf, sizeof(buf)) <= 0 || !strstr(buf, want))
				continue;
			snprintf(path, sizeof(path), "/sys/class/block/%s/dev", e->d_name);
			if (read_small(path, buf, sizeof(buf)) <= 0)
				continue;
			{
				char *colon = strchr(buf, ':');
				unsigned int maj, min;

				if (!colon)
					continue;
				*colon = 0;
				maj = atoi(buf);
				min = atoi(colon + 1);
				snprintf(dev, len, "/dev/%s", name);
				unlink(dev);
				mknod(dev, S_IFBLK | 0600, makedev(maj, min));
				close(d);
				return 1;
			}
		}
	}
	close(d);
	return 0;
}

static char out[8 << 20];

static void save_log(const char *dev)
{
	size_t used = snprintf(out, sizeof(out), "REDWOOD618LOG\n");
	int k = open("/dev/kmsg", O_RDONLY | O_NONBLOCK);
	char rec[8192];
	int fd;

	if (k < 0)
		return;
	for (;;) {
		ssize_t n = read(k, rec, sizeof(rec));

		if (n < 0) {
			if (errno == EPIPE)
				continue;
			break;
		}
		if (used + n + 1 >= sizeof(out))
			break;
		memcpy(out + used, rec, n);
		used += n;
	}
	close(k);
	out[used++] = 0;
	fd = open(dev, O_WRONLY);
	if (fd >= 0) {
		write(fd, out, used);
		fsync(fd);
		close(fd);
	}
}

int main(void)
{
	struct utsname u;
	char dev[128];
	int i;

	mkdir("/proc", 0755);
	mkdir("/sys", 0755);
	mkdir("/dev", 0755);
	mount("proc", "/proc", "proc", 0, NULL);
	mount("sysfs", "/sys", "sysfs", 0, NULL);
	mount("devtmpfs", "/dev", "devtmpfs", 0, NULL);
	mknod("/dev/kmsg", S_IFCHR | 0600, makedev(1, 11));
	mknod("/dev/null", S_IFCHR | 0666, makedev(1, 3));
	klog("started\n");

	uname(&u);
	snprintf(dir, sizeof(dir), "/lib/modules/%s", u.release);
	read_deps();
	klog("%d modules in modules.dep\n", nmods);
	load_list("modules.load");

	for (i = 0; i < 30 && !find_part("logdump", dev, sizeof(dev)); i++)
		sleep(1);
	if (i < 30) {
		char back[32] = { 0 };
		int fd;

		klog("logdump is %s after %ds\n", dev, i);
		sleep(5);
		save_log(dev);
		fd = open(dev, O_RDONLY);
		if (fd >= 0) {
			read(fd, back, 13);
			close(fd);
		}
		if (!strcmp(back, "REDWOOD618LOG")) {
			klog("log saved and read back\n");
			sync();
			my_syscall4(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
				    LINUX_REBOOT_CMD_RESTART2, "bootloader");
		}
		klog("log did not read back\n");
	} else {
		klog("logdump never showed up\n");
	}

	/* Crash on purpose: after an unclean reset the bootloader keeps the
	 * first seconds of the boot log in the minidump partition. */
	sync();
	{
		int t = open("/proc/sysrq-trigger", O_WRONLY);

		if (t >= 0)
			write(t, "c", 1);
	}
	for (;;)
		pause();
}
