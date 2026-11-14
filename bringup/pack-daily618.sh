#!/bin/bash
# A 6.18 boot image for normal use on a slot: the slot's own generic ramdisk
# and init (KernelSU's 6.12 loader taken out), the real fstab, and the 6.18
# modules in /lib/modules/<release>, which first stage init prefers over the
# vendor ramdisk's. vendor_boot and dtbo stay the slot's own.
# Usage: pack-daily618.sh <slot boot.img> <slot vendor_boot.img>   (run pack-bringup618.sh first)
set -e
BOOT=${1:?boot.img}; VBOOT=${2:?vendor_boot.img}
R=${R:-$HOME/r618}; O=$R/out; T=$R/tools; W=$R/pack-daily
UNPACK="python3 $T/unpack_bootimg"; MK="python3 $T/mkbootimg/mkbootimg.py"
REL=$(cat $O/include/config/kernel.release)
SRC=$R/pack/rd/lib/modules/$REL
[ -f $SRC/modules.all ] || { echo "run pack-bringup618.sh first"; exit 1; }
BOOTARGS=${BOOTARGS:-"panic=5 deferred_probe_timeout=-1 iommu.strict=1 redwood.nlmsg_legacy"}

rm -rf $W; mkdir -p $W/rd
$UNPACK --boot_img $BOOT --out $W/b >/dev/null
(cd $W/rd && lz4 -dc $W/b/ramdisk | cpio -id --quiet)
if [ -f $W/rd/init.real ]; then
	rm -f $W/rd/init $W/rd/kernelsu.ko $W/rd/ksu_config
	mv $W/rd/init.real $W/rd/init
fi

MD=$W/rd/lib/modules/$REL; mkdir -p $MD
cp $SRC/*.ko $SRC/modules.dep $MD/
rm -f $MD/testguard.ko $MD/logcap.ko
for f in modules.alias modules.softdep modules.options modules.blocklist; do : > $MD/$f; done
grep -v -e testguard.ko -e logcap.ko $SRC/modules.dep > $MD/modules.dep
{
	echo ufs-qcom.ko; echo bootlog.ko
	grep -vxE "${SKIP:+$SKIP|}ufs-qcom\.ko|testguard\.ko|logcap\.ko|bootlog\.ko|tz_log_dlkm\.ko|qcom_lpm\.ko|coresight.*\.ko|qcom_wdt_core\.ko|qcom_soc_wdt\.ko" $SRC/modules.all
} | awk '!seen[$0]++' | while read -r m; do [ -f $MD/$m ] && echo $m; done > $MD/modules.load

(cd $W/rd && find . | LC_ALL=C sort | cpio -o -H newc -R 0:0 --quiet) | lz4 -l -12 --favor-decSpeed -q > $W/ramdisk.lz4
BARGS=$($UNPACK --boot_img $BOOT --out $W/b --format=mkbootimg)
eval "set -- $BARGS"
args=(); while [ $# -gt 0 ]; do
	case "$1" in
	--kernel) args+=("$1" "$O/arch/arm64/boot/Image"); shift 2 ;;
	--ramdisk) args+=("$1" "$W/ramdisk.lz4"); shift 2 ;;
	--cmdline|--output|-o) shift 2 ;;
	*) args+=("$1"); shift ;;
	esac
done
$MK "${args[@]}" --cmdline "$BOOTARGS" --output $W/boot-618.img
echo "init: $(file -b $W/rd/init | cut -c1-40); modules.load: $(wc -l < $MD/modules.load); first: $(head -2 $MD/modules.load | tr '\n' ' ')"
grep -cE "testguard|logcap" $MD/modules.load || true
ls -la $W/boot-618.img; sha256sum $W/boot-618.img
