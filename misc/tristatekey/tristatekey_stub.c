// SPDX-License-Identifier: GPL-2.0-only
/* Temporary lemonadep bring-up stub for crDroid's alert-slider proc node.
 * Reports the middle/normal position until the real hall-sensor stack is ported.
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/uaccess.h>

static struct proc_dir_entry *tristate_dir;

static int tri_state_show(struct seq_file *m, void *v)
{
	seq_puts(m, "2\n");
	return 0;
}

static int tri_state_open(struct inode *inode, struct file *file)
{
	return single_open(file, tri_state_show, NULL);
}

static const struct proc_ops tri_state_proc_ops = {
	.proc_open = tri_state_open,
	.proc_read = seq_read,
	.proc_lseek = seq_lseek,
	.proc_release = single_release,
};

static int __init tristatekey_stub_init(void)
{
	tristate_dir = proc_mkdir("tristatekey", NULL);
	if (!tristate_dir)
		return -ENOMEM;
	if (!proc_create("tri_state", 0644, tristate_dir, &tri_state_proc_ops)) {
		proc_remove(tristate_dir);
		return -ENOMEM;
	}
	pr_info("tristatekey_stub: registered middle-position proc node\n");
	return 0;
}

static void __exit tristatekey_stub_exit(void)
{
	proc_remove(tristate_dir);
}

module_init(tristatekey_stub_init);
module_exit(tristatekey_stub_exit);
MODULE_DESCRIPTION("lemonadep temporary tri-state proc stub");
MODULE_LICENSE("GPL");
