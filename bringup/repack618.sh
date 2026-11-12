#!/bin/bash
# Repack both RAM boot images from vb/allven3 (shell image first: the AOSPA
# image takes its modules from the shell image's staging tree).
set -e
cd ~/r618; . env.sh
EXTRA="hci_uart.ko btqca.ko btbcm.ko" BOOTARGS="panic=0 printk.devkmsg=on deferred_probe_timeout=-1 iommu.strict=1" INIT=bringup/shell618 LOADLIST=safe.load DTB=out-dt/yupik-p3.dtb VENDOR=vb/allven3 bash pack-bringup618.sh slots/boot_a.img slots/vendor_boot_a.img 2>&1 | grep -iE "first stage"
cp pack/boot.img ramboot/boot-ram.img
BOOTARGS="panic=5 printk.devkmsg=on deferred_probe_timeout=-1 iommu.strict=1 binder.impl=rust redwood.oops_continue panic_on_oops=0 redwood_splashcon.enable=0" bash pack-aospa618.sh slots/boot_a.img slots/vendor_boot_a.img 2>&1 | tail -1
cp pack-aospa/boot-aospa.img ramboot/boot-aospa.img
M=pack-aospa/rd/lib/modules/*/
for m in msm-vidc.ko logcap.ko camera.ko; do cmp -s vb/allven3/$m $(echo $M)$m && echo "$m: current" || echo "$m: STALE"; done
sha256sum ramboot/*.img
echo DONE
