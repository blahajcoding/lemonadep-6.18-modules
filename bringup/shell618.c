// SPDX-License-Identifier: GPL-2.0
/*
 * Bring-up USB shell for 6.18 on redwood, built with the kernel's nolibc.
 *
 * Loads the first stage modules (dependencies first from modules.dep), saves
 * the kernel log to the empty logdump partition, then brings up a USB ACM
 * gadget through configfs and serves a small command shell on /dev/ttyGS0
 * (ttyACM0 on the computer). It mounts nothing on its own; the mount command
 * is there for read-only firmware partitions.
 *
 * Commands: help, dmesg [n], cat <f>, ls <dir>, echo <text> > <f>,
 * insmod <f> [args], rmmod <name>, mkdir <d>, mount <part> <dir> <type> [ro],
 * umount <dir>, lsmod, mods, log, sync, rb, reboot, poweroff
 */
#include "nolibc.h"
#include <linux/reboot.h>
#include <linux/blk-crypto.h>
#include <linux/dm-ioctl.h>

#define MAX_MODS 1024

static void sync(void)
{
	my_syscall0(__NR_sync);
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
	int fd, n = snprintf(buf, sizeof(buf), "<3>shell618: ");

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

static char *slurp(const char *path, size_t *lenp)
{
	size_t cap = 1 << 16, len = 0;
	char *buf = malloc(cap);
	int fd = open(path, O_RDONLY);
	ssize_t n;

	if (fd < 0 || !buf) {
		if (fd >= 0)
			close(fd);
		free(buf);
		return NULL;
	}
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
	if (lenp)
		*lenp = len;
	return buf;
}

static int write_str(const char *path, const char *s)
{
	int fd = open(path, O_WRONLY);
	int r;

	if (fd < 0)
		return -errno;
	r = write(fd, s, strlen(s));
	close(fd);
	return r < 0 ? -errno : 0;
}

/* ---------- module loading ---------- */

static void read_deps(void)
{
	char path[512], *txt, *line, *next;

	snprintf(path, sizeof(path), "%s/modules.dep", dir);
	txt = slurp(path, NULL);
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

static long finit(const char *path, const char *args)
{
	int fd = open(path, O_RDONLY);
	long r;

	if (fd < 0)
		return -errno;
	r = my_syscall3(__NR_finit_module, fd, args ? args : "", 0);
	close(fd);
	return r;
}

static int load(const char *name)
{
	struct mod *m = find(name);
	char path[512], *deps, *tok;
	int ret = 0;
	long r;

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
	r = finit(path, "");
	if (r < 0 && r != -EEXIST) {
		klog("load %s failed: %ld\n", name, -r);
		ret = -1;
	}
	m->state = ret ? 3 : 2;
	if (ret)
		nbad++;
	else
		nok++;
	return ret;
}

static int save_log(void);
static int log_ready;

/*
 * Load the list in order. Once logdump is reachable, save the kernel log
 * after every module, so a module that takes the kernel down leaves its
 * name behind as the last one tried.
 */
static void load_list(const char *list)
{
	char path[512], *txt, *line, *next;

	snprintf(path, sizeof(path), "%s/%s", dir, list);
	txt = slurp(path, NULL);
	if (!txt) {
		klog("no %s\n", list);
		return;
	}
	for (line = txt; line && *line; line = next) {
		struct mod *m;

		next = strchr(line, '\n');
		if (next)
			*next++ = 0;
		if (!line[0])
			continue;
		m = find(line);
		if (m && m->state)
			continue;
		klog("loading %s\n", line);
		if (log_ready)
			save_log();
		else
			log_ready = !save_log();
		load(line);
	}
	klog("%s done: %d loaded, %d failed\n", list, nok, nbad);
}

/* ---------- block device lookup and the log ---------- */

struct linux_dirent64_ {
	unsigned long long d_ino;
	long long d_off;
	unsigned short d_reclen;
	unsigned char d_type;
	char d_name[];
};

typedef int (*dent_fn)(const char *name, unsigned char type, void *ctx);

static int each_dent(const char *path, dent_fn fn, void *ctx)
{
	char dents[16384];
	int d = open(path, O_RDONLY | O_DIRECTORY);
	long n;

	if (d < 0)
		return -errno;
	while ((n = my_syscall3(__NR_getdents64, d, dents, sizeof(dents))) > 0) {
		long off = 0;

		while (off < n) {
			struct linux_dirent64_ *e = (void *)(dents + off);

			off += e->d_reclen;
			if (e->d_name[0] == '.')
				continue;
			if (fn(e->d_name, e->d_type, ctx)) {
				close(d);
				return 1;
			}
		}
	}
	close(d);
	return 0;
}

struct part_ctx {
	const char *want;
	char *dev;
	size_t len;
	int all;		/* collect every match into devs[] */
};

static char devs[4][64];
static int ndevs;

static int part_cb(const char *name, unsigned char type, void *vctx)
{
	struct part_ctx *c = vctx;
	char path[512], *txt, *colon;

	(void)type;
	snprintf(path, sizeof(path), "/sys/class/block/%s/uevent", name);
	txt = slurp(path, NULL);
	if (!txt)
		return 0;
	if (!strstr(txt, c->want)) {
		free(txt);
		return 0;
	}
	free(txt);
	snprintf(path, sizeof(path), "/sys/class/block/%s/dev", name);
	txt = slurp(path, NULL);
	if (!txt)
		return 0;
	colon = strchr(txt, ':');
	if (colon) {
		*colon = 0;
		snprintf(c->dev, c->len, "/dev/%s", name);
		unlink(c->dev);
		mknod(c->dev, S_IFBLK | 0600, makedev(atoi(txt), atoi(colon + 1)));
		if (c->all && ndevs < 4)
			snprintf(devs[ndevs++], sizeof(devs[0]), "%s", c->dev);
	}
	free(txt);
	return colon != NULL && !c->all;
}

static int find_part(const char *name, char *dev, size_t len)
{
	char want[128];
	struct part_ctx c = { want, dev, len, 0 };

	snprintf(want, sizeof(want), "PARTNAME=%s\n", name);
	return each_dent("/sys/class/block", part_cb, &c) == 1;
}

static char logbuf[8 << 20];

static size_t read_kmsg(char *out, size_t cap)
{
	int k = open("/dev/kmsg", O_RDONLY | O_NONBLOCK);
	char rec[8192];
	size_t used = 0;

	if (k < 0)
		return 0;
	for (;;) {
		ssize_t n = read(k, rec, sizeof(rec));
		char *msg;

		if (n < 0) {
			if (errno == EPIPE)
				continue;
			break;
		}
		rec[n < (ssize_t)sizeof(rec) ? n : (ssize_t)sizeof(rec) - 1] = 0;
		/* "prio,seq,ts,flags;message\n" -> "[ts] message" */
		msg = strchr(rec, ';');
		if (msg) {
			char *f1 = strchr(rec, ','), *f2 = f1 ? strchr(f1 + 1, ',') : NULL;
			char *f3 = f2 ? strchr(f2 + 1, ',') : NULL;
			char *e = strchr(msg, '\n');
			long long us = f2 ? strtoll(f2 + 1, NULL, 10) : 0;
			int w;

			(void)f3;
			if (e)
				e[1] = 0;
			if (used + 32 + strlen(msg) >= cap)
				break;
			w = snprintf(out + used, cap - used, "[%5lld.%06lld] %s",
				     us / 1000000, us % 1000000, msg + 1);
			used += w;
		}
	}
	close(k);
	return used;
}

/*
 * redwood has two logdump partitions. Each boot writes to the one holding
 * the older log (a 6.18 boot counter in the header; anything else counts as
 * oldest), so a boot that crashes keeps its log through the next one.
 */
static char logdev[64];
static unsigned int logseq;

static int pick_logdev(void)
{
	char tmp[64], hdr[64];
	struct part_ctx c = { "PARTNAME=logdump\n", tmp, sizeof(tmp), 1 };
	unsigned int best = ~0u, top = 0;
	int i;

	if (logdev[0])
		return 0;
	/*
	 * PID 1 and its children each call this; the first one to pick
	 * records the choice in /.logdev so they all write the same
	 * partition and the other one keeps the previous boot's log.
	 */
	{
		char *t = slurp("/.logdev", NULL), *sp;

		if (t && (sp = strchr(t, ' '))) {
			*sp = 0;
			snprintf(logdev, sizeof(logdev), "%s", t);
			logseq = strtoul(sp + 1, NULL, 10);
			free(t);
			return 0;
		}
		free(t);
	}
	ndevs = 0;
	each_dent("/sys/class/block", part_cb, &c);
	if (!ndevs)
		return -ENODEV;
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
		/*
		 * An Android log is what a shell boot is usually there to read:
		 * overwrite the other partition instead, even if it is newer.
		 */
		if (strstr(hdr, " android"))
			seq += 1u << 30;
		if (seq < best) {
			best = seq;
			snprintf(logdev, sizeof(logdev), "%s", devs[i]);
		}
	}
	logseq = top + 1;
	{
		char rec[96];
		int fd = open("/.logdev", O_WRONLY | O_CREAT | O_EXCL, 0600);

		if (fd < 0) {
			/* someone else picked first: use theirs */
			logdev[0] = 0;
			for (i = 0; i < 50 && !logdev[0]; i++) {
				char *t = slurp("/.logdev", NULL), *sp;

				if (t && (sp = strchr(t, ' '))) {
					*sp = 0;
					snprintf(logdev, sizeof(logdev), "%s", t);
					logseq = strtoul(sp + 1, NULL, 10);
				}
				free(t);
				if (!logdev[0])
					usleep(20000);
			}
			return logdev[0] ? 0 : -EAGAIN;
		}
		snprintf(rec, sizeof(rec), "%s %u\n", logdev, logseq);
		write(fd, rec, strlen(rec));
		close(fd);
	}
	klog("logdump: writing %s as boot %u (%d partitions)\n", logdev, logseq, ndevs);
	return 0;
}

static int save_log(void)
{
	const char *dev = logdev;
	size_t used;
	int fd;

	if (pick_logdev())
		return -ENODEV;
	used = snprintf(logbuf, sizeof(logbuf), "REDWOOD618LOG seq=%08u\n", logseq);
	used += read_kmsg(logbuf + used, sizeof(logbuf) - used - 1);
	logbuf[used++] = 0;
	fd = open(dev, O_WRONLY);
	if (fd < 0)
		return -errno;
	write(fd, logbuf, used);
	fsync(fd);
	close(fd);
	return 0;
}

/* ---------- USB ACM gadget ---------- */

static char udc[128];

static int udc_cb(const char *name, unsigned char type, void *ctx)
{
	(void)type;
	(void)ctx;
	snprintf(udc, sizeof(udc), "%s", name);
	return 1;
}

/* The Type-C side reports nothing on its own yet; force device mode */
static int role_cb(const char *name, unsigned char type, void *ctx)
{
	char path[256];

	(void)type;
	(void)ctx;
	snprintf(path, sizeof(path), "/sys/class/usb_role/%s/role", name);
	klog("usb role %s -> device: %d\n", name, write_str(path, "device"));
	return 0;
}

static int gadget_up(void)
{
	const char *g = "/config/usb_gadget/g1";
	char path[256];
	int i;

	each_dent("/sys/class/usb_role", role_cb, NULL);

	mkdir("/config", 0755);
	mount("configfs", "/config", "configfs", 0, NULL);
	mkdir(g, 0755);
	snprintf(path, sizeof(path), "%s/idVendor", g);
	write_str(path, "0x18d1");
	snprintf(path, sizeof(path), "%s/idProduct", g);
	write_str(path, "0x4ee7");
	snprintf(path, sizeof(path), "%s/strings/0x409", g);
	mkdir(path, 0755);
	snprintf(path, sizeof(path), "%s/strings/0x409/serialnumber", g);
	write_str(path, "redwood618");
	snprintf(path, sizeof(path), "%s/strings/0x409/manufacturer", g);
	write_str(path, "redwood");
	snprintf(path, sizeof(path), "%s/strings/0x409/product", g);
	write_str(path, "redwood 6.18 bring-up shell");
	snprintf(path, sizeof(path), "%s/functions/acm.usb0", g);
	mkdir(path, 0755);
	snprintf(path, sizeof(path), "%s/configs/c.1", g);
	mkdir(path, 0755);
	snprintf(path, sizeof(path), "%s/configs/c.1/strings/0x409", g);
	mkdir(path, 0755);
	snprintf(path, sizeof(path), "%s/configs/c.1/acm.usb0", g);
	symlink("/config/usb_gadget/g1/functions/acm.usb0", path);

	for (i = 0; i < 30; i++) {
		udc[0] = 0;
		each_dent("/sys/class/udc", udc_cb, NULL);
		if (udc[0])
			break;
		sleep(1);
	}
	if (!udc[0]) {
		klog("no UDC after 30s\n");
		return -ENODEV;
	}
	snprintf(path, sizeof(path), "%s/UDC", g);
	i = write_str(path, udc);
	klog("gadget on %s: %d\n", udc, i);
	return i;
}

/* ---------- the shell ---------- */

static int tty = -1;

static void out(const char *s, size_t n)
{
	while (n) {
		ssize_t w = write(tty, s, n);

		if (w <= 0)
			return;
		s += w;
		n -= w;
	}
}

static void outs(const char *s)
{
	out(s, strlen(s));
}

static void outf(const char *fmt, ...)
{
	char buf[1024];
	va_list ap;
	int n;

	va_start(ap, fmt);
	n = vsnprintf(buf, sizeof(buf), fmt, ap);
	va_end(ap);
	if (n > (int)sizeof(buf) - 1)
		n = sizeof(buf) - 1;
	out(buf, n);
}

static void cat_crlf(const char *s, size_t n)
{
	size_t i, start = 0;

	for (i = 0; i < n; i++) {
		if (s[i] == '\n') {
			out(s + start, i - start);
			out("\r\n", 2);
			start = i + 1;
		}
	}
	out(s + start, n - start);
}

static int ls_cb(const char *name, unsigned char type, void *ctx)
{
	(void)ctx;
	outf("%s%s\r\n", name, type == 4 ? "/" : "");
	return 0;
}

static void reboot_to(const char *target)
{
	sync();
	if (target)
		my_syscall4(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
			    LINUX_REBOOT_CMD_RESTART2, target);
	else
		my_syscall4(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
			    LINUX_REBOOT_CMD_POWER_OFF, 0);
}

/* ---------- ICE check ---------- */

/*
 * icetest: prove that UFS inline encryption with hardware-wrapped keys works
 * before Android is allowed near /data. TZ generates a long-term wrapped key
 * and prepares it for this boot; a dm-default-key mapping with wrappedkey_v0
 * (what metadata encryption uses) is laid over 4 MiB in the middle of the
 * logdump partition this boot does not write. Data written through the
 * mapping must read back the same, and must read differently from the raw
 * partition. The mapping is taken down at the end.
 */
#define ICE_START	65536ULL	/* sectors: 32 MiB into logdump */
#define ICE_LEN		8192ULL		/* sectors: 4 MiB */

static unsigned char ice_lt[256], ice_eph[256];
static char ice_buf[(ICE_LEN * 512) + 4096], ice_raw[(ICE_LEN * 512) + 4096];

static int dm_call(int ctl, unsigned long cmd, struct dm_ioctl *io, size_t size,
		   const char *name)
{
	io->version[0] = DM_VERSION_MAJOR;
	io->version[1] = 0;
	io->version[2] = 0;
	io->data_size = size;
	io->data_start = sizeof(*io);
	snprintf(io->name, sizeof(io->name), "%s", name);
	return ioctl(ctl, cmd, io);
}

static int bdev_rw(const char *dev, int wr, char *buf, size_t len, unsigned long long off)
{
	int fd = open(dev, (wr ? O_WRONLY : O_RDONLY) | O_DIRECT);
	long r;

	if (fd < 0)
		return -errno;
	r = lseek(fd, off, SEEK_SET);
	if (r >= 0)
		r = wr ? write(fd, buf, len) : read(fd, buf, len);
	if (wr)
		fsync(fd);
	close(fd);
	return r == (long)len ? 0 : (r < 0 ? (int)r : -EIO);
}

static void icetest(void)
{
	static char tbl[sizeof(struct dm_ioctl) + sizeof(struct dm_target_spec) + 1024];
	struct dm_ioctl *io = (struct dm_ioctl *)tbl;
	struct dm_target_spec *sp = (struct dm_target_spec *)(tbl + sizeof(*io));
	struct blk_crypto_generate_key_arg g;
	struct blk_crypto_prepare_key_arg pr;
	char *buf = (char *)(((unsigned long)ice_buf + 4095) & ~4095UL);
	char *raw = (char *)(((unsigned long)ice_raw + 4095) & ~4095UL);
	char other[64], hex[600], devno[32], *params;
	unsigned int maj, mnr;
	size_t i, len = ICE_LEN * 512, same = 0, plain = 0;
	int fd, ctl, r;

	pick_logdev();
	ndevs = 0;
	{
		char tmp[64];
		struct part_ctx c = { "PARTNAME=logdump\n", tmp, sizeof(tmp), 1 };

		each_dent("/sys/class/block", part_cb, &c);
	}
	other[0] = 0;
	for (i = 0; i < (size_t)ndevs; i++)
		if (strcmp(devs[i], logdev))
			snprintf(other, sizeof(other), "%s", devs[i]);
	if (!other[0]) {
		outs("icetest: no spare logdump partition\r\n");
		return;
	}
	{
		char path[96], *t, *colon;

		snprintf(path, sizeof(path), "/sys/class/block/%s/dev", strrchr(other, '/') + 1);
		t = slurp(path, NULL);
		if (!t || !(colon = strchr(t, ':'))) {
			outs("icetest: no dev number\r\n");
			free(t);
			return;
		}
		*colon = 0;
		maj = atoi(t);
		mnr = atoi(colon + 1);
		free(t);
	}
	outf("icetest: scratch %s (%u:%u) sectors %llu+%llu, log stays on %s\r\n",
	     other, maj, mnr, ICE_START, ICE_LEN, logdev);

	fd = open(other, O_RDWR);
	if (fd < 0) {
		outf("icetest: open %s: %d\r\n", other, errno);
		return;
	}
	memset(&g, 0, sizeof(g));
	g.lt_key_ptr = (unsigned long)ice_lt;
	g.lt_key_size = sizeof(ice_lt);
	r = ioctl(fd, BLKCRYPTOGENERATEKEY, &g);
	outf("icetest: generate key: %d (%d), %llu bytes\r\n", r, r < 0 ? errno : 0,
	     (unsigned long long)g.lt_key_size);
	if (r < 0) {
		close(fd);
		return;
	}
	memset(&pr, 0, sizeof(pr));
	pr.lt_key_ptr = (unsigned long)ice_lt;
	pr.lt_key_size = g.lt_key_size;
	pr.eph_key_ptr = (unsigned long)ice_eph;
	pr.eph_key_size = sizeof(ice_eph);
	r = ioctl(fd, BLKCRYPTOPREPAREKEY, &pr);
	close(fd);
	outf("icetest: prepare key: %d (%d), %llu bytes\r\n", r, r < 0 ? errno : 0,
	     (unsigned long long)pr.eph_key_size);
	if (r < 0)
		return;
	for (i = 0; i < pr.eph_key_size; i++)
		snprintf(hex + 2 * i, 3, "%02x", ice_eph[i]);

	mknod("/dev/dmctl", S_IFCHR | 0600, makedev(10, 236));
	ctl = open("/dev/dmctl", O_RDWR);
	if (ctl < 0) {
		outf("icetest: /dev/mapper/control: %d\r\n", errno);
		return;
	}
	memset(tbl, 0, sizeof(tbl));
	dm_call(ctl, DM_DEV_REMOVE, io, sizeof(*io), "icetest");
	memset(tbl, 0, sizeof(tbl));
	r = dm_call(ctl, DM_DEV_CREATE, io, sizeof(*io), "icetest");
	outf("icetest: dm create: %d (%d)\r\n", r, r < 0 ? errno : 0);
	if (r < 0)
		goto out;

	memset(tbl, 0, sizeof(tbl));
	io->target_count = 1;
	sp->sector_start = 0;
	sp->length = ICE_LEN;
	snprintf(sp->target_type, sizeof(sp->target_type), "default-key");
	params = (char *)(sp + 1);
	snprintf(devno, sizeof(devno), "%u:%u", maj, mnr);
	snprintf(params, 1024, "aes-xts-plain64 %s 0 %s %llu 4 allow_discards sector_size:4096 iv_large_sectors wrappedkey_v0",
		 hex, devno, ICE_START);
	sp->next = 0;
	r = dm_call(ctl, DM_TABLE_LOAD, io, sizeof(tbl), "icetest");
	outf("icetest: dm table load: %d (%d)\r\n", r, r < 0 ? errno : 0);
	if (r < 0)
		goto remove;
	memset(tbl, 0, sizeof(tbl));
	r = dm_call(ctl, DM_DEV_SUSPEND, io, sizeof(*io), "icetest");
	outf("icetest: dm resume: %d (%d), dev %u:%u\r\n", r, r < 0 ? errno : 0,
	     (unsigned int)(io->dev >> 8) & 0xfff, (unsigned int)((io->dev & 0xff) | ((io->dev >> 12) & 0xfff00)));
	if (r < 0)
		goto remove;
	unlink("/dev/icetest");
	mknod("/dev/icetest", S_IFBLK | 0600, io->dev);

	for (i = 0; i < len; i++)
		buf[i] = (char)(i * 7 + (i >> 9) * 13 + 0x5a);
	r = bdev_rw("/dev/icetest", 1, buf, len, 0);
	outf("icetest: write through ICE: %d\r\n", r);
	if (r)
		goto remove;
	memset(buf, 0, len);
	r = bdev_rw("/dev/icetest", 0, buf, len, 0);
	for (i = 0; i < len; i++)
		same += buf[i] == (char)(i * 7 + (i >> 9) * 13 + 0x5a);
	outf("icetest: read back through ICE: %d, %zu/%zu bytes match\r\n", r, same, len);
	r = bdev_rw(other, 0, raw, len, ICE_START * 512);
	for (i = 0; i < len; i++)
		plain += raw[i] == (char)(i * 7 + (i >> 9) * 13 + 0x5a);
	outf("icetest: raw partition: %d, %zu/%zu bytes equal the plaintext\r\n", r, plain, len);
	outf("icetest: %s\r\n", same == len && plain < len / 64 ? "PASS: ICE encrypts and decrypts with a wrapped key" :
	     same != len ? "FAIL: data does not survive the round trip" :
			   "FAIL: data reached the disk in the clear");
remove:
	memset(tbl, 0, sizeof(tbl));
	r = dm_call(ctl, DM_DEV_REMOVE, io, sizeof(*io), "icetest");
	outf("icetest: dm remove: %d\r\n", r);
out:
	close(ctl);
}

static void run(char *line)
{
	char *argv[16];
	int argc = 0;
	char *p = line, *redir = NULL;

	redir = strchr(line, '>');
	if (redir) {
		*redir++ = 0;
		while (*redir == ' ')
			redir++;
	}
	while (*p && argc < 15) {
		while (*p == ' ')
			p++;
		if (!*p)
			break;
		argv[argc++] = p;
		while (*p && *p != ' ')
			p++;
		if (*p)
			*p++ = 0;
	}
	argv[argc] = NULL;
	if (!argc)
		return;

	if (!strcmp(argv[0], "help")) {
		outs("help dmesg [n] | cat f | ls d | echo t > f | insmod f [args] | rmmod m | modprobe m | loadall\r\n"
		     "mkdir d | mount <partname|/dev/x> dir type [ro] | umount dir\r\n"
		     "lsmod | mods | log | icetest | sync | rb | reboot | poweroff\r\n");
	} else if (!strcmp(argv[0], "dmesg")) {
		size_t n = read_kmsg(logbuf, sizeof(logbuf) - 1), start = 0;
		long tail = argc > 1 ? atol(argv[1]) * 120 : 0;

		if (tail && (size_t)tail < n)
			start = n - tail;
		cat_crlf(logbuf + start, n - start);
	} else if (!strcmp(argv[0], "cat") && argc > 1) {
		size_t n;
		char *t = slurp(argv[1], &n);

		if (!t)
			outf("cat: %s: %d\r\n", argv[1], errno);
		else {
			cat_crlf(t, n);
			free(t);
		}
	} else if (!strcmp(argv[0], "ls")) {
		if (each_dent(argc > 1 ? argv[1] : "/", ls_cb, NULL) < 0)
			outf("ls: %d\r\n", errno);
	} else if (!strcmp(argv[0], "echo") && redir) {
		char buf[1024] = "";
		int i, r;

		for (i = 1; i < argc; i++) {
			strncat(buf, argv[i], sizeof(buf) - strlen(buf) - 2);
			if (i + 1 < argc)
				strncat(buf, " ", sizeof(buf) - strlen(buf) - 1);
		}
		r = write_str(redir, buf);
		if (r)
			outf("echo: %d\r\n", r);
	} else if (!strcmp(argv[0], "insmod") && argc > 1) {
		char args[512] = "";
		int i;
		long r;

		for (i = 2; i < argc; i++) {
			strncat(args, argv[i], sizeof(args) - strlen(args) - 2);
			strncat(args, " ", sizeof(args) - strlen(args) - 1);
		}
		r = finit(argv[1], args);
		outf("insmod: %ld\r\n", r);
	} else if (!strcmp(argv[0], "rmmod") && argc > 1) {
		long r = my_syscall2(__NR_delete_module, argv[1], O_NONBLOCK);

		outf("rmmod: %ld\r\n", r);
	} else if (!strcmp(argv[0], "modprobe") && argc > 1) {
		char name[128];
		struct mod *m;
		int r;

		snprintf(name, sizeof(name), "%s%s", argv[1],
			 strstr(argv[1], ".ko") ? "" : ".ko");
		m = find(name);
		if (m && m->state == 3)
			m->state = 0;
		r = load(name);
		outf("modprobe %s: %d\r\n", name, r);
	} else if (!strcmp(argv[0], "loadall")) {
		char path[512], *txt, *l, *nx;
		int ok = 0, bad = 0;

		snprintf(path, sizeof(path), "%s/modules.all", dir);
		txt = slurp(path, NULL);
		for (l = txt; l && *l; l = nx) {
			struct mod *m;

			nx = strchr(l, '\n');
			if (nx)
				*nx++ = 0;
			if (!*l)
				continue;
			m = find(l);
			if (m && m->state)
				continue;
			outf("loading %s\r\n", l);
			klog("loadall: %s\n", l);
			save_log();
			if (load(l))
				bad++;
			else
				ok++;
		}
		free(txt);
		outf("loadall: %d loaded, %d failed\r\n", ok, bad);
	} else if (!strcmp(argv[0], "mkdir") && argc > 1) {
		outf("mkdir: %d\r\n", mkdir(argv[1], 0755) ? errno : 0);
	} else if (!strcmp(argv[0], "mount") && argc > 3) {
		char dev[64];
		const char *src = argv[1];
		int r;

		if (src[0] != '/') {
			if (!find_part(src, dev, sizeof(dev))) {
				outf("mount: no partition %s\r\n", src);
				return;
			}
			src = dev;
		}
		mkdir(argv[2], 0755);
		r = mount(src, argv[2], argv[3],
			  argc > 4 && !strcmp(argv[4], "ro") ? MS_RDONLY : 0,
			  NULL);
		outf("mount %s on %s: %d\r\n", src, argv[2], r ? errno : 0);
	} else if (!strcmp(argv[0], "umount") && argc > 1) {
		outf("umount: %d\r\n", umount2(argv[1], 0) ? errno : 0);
	} else if (!strcmp(argv[0], "lsmod")) {
		size_t n;
		char *t = slurp("/proc/modules", &n);

		if (t) {
			cat_crlf(t, n);
			free(t);
		}
	} else if (!strcmp(argv[0], "mods")) {
		int i;

		for (i = 0; i < nmods; i++)
			if (mods[i].state == 3)
				outf("failed: %s\r\n", mods[i].name);
		outf("%d loaded, %d failed\r\n", nok, nbad);
	} else if (!strcmp(argv[0], "log")) {
		outf("log: %d\r\n", save_log());
	} else if (!strcmp(argv[0], "icetest")) {
		icetest();
	} else if (!strcmp(argv[0], "sync")) {
		sync();
	} else if (!strcmp(argv[0], "rb")) {
		reboot_to("bootloader");
	} else if (!strcmp(argv[0], "reboot")) {
		reboot_to("");
	} else if (!strcmp(argv[0], "poweroff")) {
		reboot_to(NULL);
	} else {
		outf("unknown: %s (try help)\r\n", argv[0]);
	}
}

static void shell(void)
{
	char line[1024];
	size_t len = 0;
	char c;

	outs("\r\nredwood 6.18 bring-up shell. help for commands.\r\n# ");
	for (;;) {
		ssize_t n = read(tty, &c, 1);

		if (n <= 0) {
			/*
			 * A module that resets the controller (loadall) makes the
			 * host enumerate the gadget again and hangs up ttyGS0:
			 * open it again instead of reading a dead port forever.
			 */
			int t;

			sleep(1);
			t = open("/dev/ttyGS0", O_RDWR | O_NOCTTY);
			if (t >= 0) {
				close(tty);
				tty = t;
				klog("reopened ttyGS0\n");
			}
			continue;
		}
		if (c == '\r' || c == '\n') {
			out("\r\n", 2);
			line[len] = 0;
			run(line);
			len = 0;
			outs("# ");
		} else if (c == 0x7f || c == 8) {
			if (len) {
				len--;
				outs("\b \b");
			}
		} else if (len < sizeof(line) - 1) {
			line[len++] = c;
			out(&c, 1);
		}
	}
}

int main(void)
{
	struct utsname u;
	int i, r;

	mkdir("/proc", 0755);
	mkdir("/sys", 0755);
	mkdir("/dev", 0755);
	mount("proc", "/proc", "proc", 0, NULL);
	mount("sysfs", "/sys", "sysfs", 0, NULL);
	mount("devtmpfs", "/dev", "devtmpfs", 0, NULL);
	mknod("/dev/kmsg", S_IFCHR | 0600, makedev(1, 11));
	mknod("/dev/null", S_IFCHR | 0666, makedev(1, 3));
	write_str("/proc/sys/kernel/printk_devkmsg", "on\n");
	klog("started\n");

	/*
	 * Log keeper: write the whole kernel log to logdump every 2 s for the
	 * life of the boot, so even a reset leaves the last seconds behind.
	 */
	if (fork() == 0) {
		for (;;) {
			save_log();
			sleep(2);
		}
	}

	/*
	 * Report child: after 40 s print what is deferred and which module is
	 * still loading, even if PID 1 is stuck in a module's probe.
	 */
	if (fork() == 0) {
		char *t, *l, *nx;

		sleep(20);
		mkdir("/sys/kernel/debug", 0755);
		mount("debugfs", "/sys/kernel/debug", "debugfs", 0, NULL);
		klog("==== 20s report: deferred devices ====\n");
		t = slurp("/sys/kernel/debug/devices_deferred", NULL);
		for (l = t; l && *l; l = nx) {
			nx = strchr(l, '\n');
			if (nx)
				*nx++ = 0;
			if (*l)
				klog("DEFER %s\n", l);
		}
		free(t);
		klog("==== log lines about smem, ufs, hwlock, phy ====\n");
		{
			size_t n = read_kmsg(logbuf, sizeof(logbuf) - 1);
			char *ln, *nl;
			int shown = 0;

			logbuf[n] = 0;
			for (ln = logbuf; ln && *ln && shown < 45; ln = nl) {
				nl = strchr(ln, '\n');
				if (nl)
					*nl++ = 0;
				if (strstr(ln, "shell618"))
					continue;
				if (strstr(ln, "smem") || strstr(ln, "SMEM") || strstr(ln, "ufs") ||
				    strstr(ln, "hwlock") || strstr(ln, "hwspin") || strstr(ln, "phy") ||
				    strstr(ln, "1d84000") || strstr(ln, "mutex")) {
					klog("LOG%s\n", strchr(ln, ']') ? strchr(ln, ']') + 1 : ln);
					shown++;
				}
			}
		}
		klog("==== drivers bound ====\n");
		{
			const char *devs[] = { "1d84000.ufshc", "1d87000.ufsphy_mem", "1d87000.ufsphy",
				"soc:qcom,smem", "qcom,smem", "1f40000.syscon", "soc:hwlock", "hwlock",
				"a600000.ssusb", "88e3000.hsphy", "88e8000.ssphy", NULL };
			int k;

			for (k = 0; devs[k]; k++) {
				char path[256], target[256];
				long r;

				snprintf(path, sizeof(path), "/sys/bus/platform/devices/%s/driver", devs[k]);
				r = my_syscall4(__NR_readlinkat, AT_FDCWD, path, target, sizeof(target) - 1);
				if (r > 0) {
					target[r] = 0;
					klog("BOUND %s -> %s\n", devs[k], strrchr(target, '/') ? strrchr(target, '/') + 1 : target);
				} else {
					snprintf(path, sizeof(path), "/sys/bus/platform/devices/%s", devs[k]);
					klog("BOUND %s: %s\n", devs[k], access(path, F_OK) ? "no device" : "no driver");
				}
			}
		}
		klog("==== modules not Live ====\n");
		t = slurp("/proc/modules", NULL);
		for (l = t; l && *l; l = nx) {
			nx = strchr(l, '\n');
			if (nx)
				*nx++ = 0;
			if (*l && !strstr(l, " Live "))
				klog("MOD %s\n", l);
		}
		free(t);
		klog("==== 20s report done, logdump save: %d ====\n", save_log());
		for (;;)
			sleep(60);
	}


	uname(&u);
	snprintf(dir, sizeof(dir), "/lib/modules/%s", u.release);
	read_deps();
	klog("%d modules in modules.dep\n", nmods);

	/* UFS first, so the log has somewhere to go; then reboot reasons */
	load("ufs-qcom.ko");
	log_ready = !save_log();
	klog("logdump %s\n", log_ready ? "reachable" : "not reachable yet");
	if (log_ready)
		save_log();

	load_list("modules.load");


	for (i = 0; i < 30 && save_log(); i++)
		sleep(1);
	klog("log %s after %ds\n", i < 30 ? "saved" : "not saved", i);

	r = gadget_up();
	if (r) {
		/*
		 * Never reboot on our own: a clean reboot leaves no dump. Wait
		 * instead; the watchdog bite makes the bootloader save the log
		 * to rawdump.
		 */
		save_log();
		klog("no USB gadget, waiting for the watchdog\n");
		for (;;)
			sleep(60);
	}

	for (i = 0; i < 60; i++) {
		tty = open("/dev/ttyGS0", O_RDWR | O_NOCTTY);
		if (tty >= 0)
			break;
		/* no devtmpfs: make the node from sysfs */
		{
			size_t n;
			char *t = slurp("/sys/class/tty/ttyGS0/dev", &n), *colon;

			if (t && (colon = strchr(t, ':'))) {
				*colon = 0;
				mknod("/dev/ttyGS0", S_IFCHR | 0600, makedev(atoi(t), atoi(colon + 1)));
			}
			free(t);
		}
		sleep(1);
	}
	if (tty < 0) {
		klog("no ttyGS0, waiting for the watchdog\n");
		save_log();
		for (;;)
			sleep(60);
	}
	klog("shell on ttyGS0\n");
	save_log();
	shell();
	return 0;
}
