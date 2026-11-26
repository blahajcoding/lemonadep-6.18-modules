#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.arch = MODULE_ARCH_INIT,
};

KSYMTAB_FUNC(tcm_get_panel, "");
SYMBOL_FLAGS(tcm_get_panel, 0x00);
KSYMTAB_FUNC(syna_tcm_bus_init, "");
SYMBOL_FLAGS(syna_tcm_bus_init, 0x00);
KSYMTAB_FUNC(syna_tcm_bus_exit, "");
SYMBOL_FLAGS(syna_tcm_bus_exit, 0x00);

MODULE_INFO(depends, "");

MODULE_ALIAS("of:N*T*Csynaptics,tcm-i2c");
MODULE_ALIAS("of:N*T*Csynaptics,tcm-i2cC*");
MODULE_ALIAS("i2c:synaptics_tcm_i2c");
