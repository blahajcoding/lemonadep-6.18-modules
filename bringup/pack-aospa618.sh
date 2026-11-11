#!/bin/bash
# AOSPA RAM boot image for 6.18 on redwood that writes nothing shared:
# the slot's own generic ramdisk with logsaver618 as /init (Android's init
# moves to /init.android), the 6.18 modules in /lib/modules/<release> (first
# stage init prefers them over the vendor ramdisk's), testguard right after
# UFS, a first stage fstab with /metadata read-only and never formatted, and
# /fstab.test, which logsaver618 binds over /vendor/etc/fstab.default: /data
# on tmpfs, persist and qmcs read-only.
# Usage: pack-aospa618.sh <boot.img> <vendor_boot.img>   (run pack-bringup618.sh first)
set -e
BOOT=${1:?boot.img}; VBOOT=${2:?vendor_boot.img}
R=~/r618; O=$R/out; T=$R/tools; W=$R/pack-aospa
UNPACK="python3 $T/unpack_bootimg"; MK="python3 $T/mkbootimg/mkbootimg.py"
REL=$(cat $O/include/config/kernel.release)
SRC=$R/pack/rd/lib/modules/$REL
[ -f $SRC/modules.all ] || { echo "run pack-bringup618.sh first"; exit 1; }
BOOTARGS=${BOOTARGS:-"panic=5 printk.devkmsg=on deferred_probe_timeout=-1 iommu.strict=1"}

rm -rf $W; mkdir -p $W/rd $W/vr
$UNPACK --boot_img $BOOT --out $W/b >/dev/null
$UNPACK --boot_img $VBOOT --out $W/vb >/dev/null
(cd $W/rd && lz4 -dc $W/b/ramdisk | cpio -id --quiet)
(cd $W/vr && { lz4 -dc $W/vb/vendor_ramdisk00 2>/dev/null || lz4 -dc $W/vb/vendor_ramdisk; } | cpio -id --quiet)

# a KernelSU patched ramdisk keeps Android's init as /init.real behind ksud's
# loader, whose kernelsu.ko is built for the slot's own kernel: skip it
if [ -f $W/rd/init.real ]; then
	rm -f $W/rd/init $W/rd/kernelsu.ko $W/rd/ksu_config
	mv $W/rd/init.real $W/rd/init.android
else
	mv $W/rd/init $W/rd/init.android
fi
cp $R/bringup/logsaver618 $W/rd/init; chmod 750 $W/rd/init

MD=$W/rd/lib/modules/$REL; mkdir -p $MD
cp $SRC/*.ko $SRC/modules.dep $MD/
for f in modules.alias modules.softdep modules.options modules.blocklist; do : > $MD/$f; done
{
	echo ufs-qcom.ko; echo testguard.ko; echo bootlog.ko; echo logcap.ko
	grep -vxE "${SKIP:+$SKIP|}ufs-qcom\.ko|testguard\.ko|logcap\.ko|bootlog\.ko|tz_log_dlkm\.ko|qcom_lpm\.ko|coresight.*\.ko|qcom_wdt_core\.ko|qcom_soc_wdt\.ko" $SRC/modules.all
} | awk '!seen[$0]++' | while read -r m; do [ -f $MD/$m ] && echo $m; done > $MD/modules.load
for m in ufs-qcom.ko testguard.ko bootlog.ko; do grep -qx $m $MD/modules.load || { echo "$m missing"; exit 1; }; done

# the test fstab, used by first stage (in the ramdisk) and second stage (bound
# over /vendor/etc/fstab.default): /data on tmpfs, /metadata and persist
# read-only without journal replay, qmcs read-only, nothing checked or formatted
FS=$W/vr/first_stage_ramdisk/fstab.default
[ -f $FS ] || { echo "no first_stage_ramdisk/fstab.default in the vendor ramdisk"; exit 1; }
awk '
$2=="/data" {print "tmpfs /data tmpfs nosuid,nodev,noatime,mode=0771,uid=1000,gid=1000 latemount"; next}
$2=="/metadata" {print $1, $2, $3, "ro,noload,nosuid,nodev", "wait,first_stage_mount"; next}
$2=="/mnt/vendor/persist" {print $1, $2, $3, "ro,noload,nosuid,nodev", "wait"; next}
$2=="/mnt/vendor/qmcs" {o=$4; sub(/^/, "ro,", o); print $1, $2, $3, o, "wait"; next}
{print}' $FS > $W/rd/fstab.test
mkdir -p $W/rd/first_stage_ramdisk
cp $W/rd/fstab.test $W/rd/first_stage_ramdisk/fstab.default
# second stage reads it from a small ext4 image whose file is labeled like
# the vendor's fstab (vendor_configs_file), which logsaver618 loop mounts
rm -rf $W/img; mkdir -p $W/img; cp $W/rd/fstab.test $W/img/fstab.default
mke2fs -q -t ext4 -O ^has_journal,^metadata_csum -b 4096 -L fstab618 -d $W/img $W/rd/fstab.img 1M
debugfs -w -R "ea_set /fstab.default security.selinux u:object_r:vendor_configs_file:s0" $W/rd/fstab.img 2>/dev/null
debugfs -R "ea_list /fstab.default" $W/rd/fstab.img 2>/dev/null | grep -q vendor_configs_file || { echo "fstab.img not labeled"; exit 1; }
grep -E "/data|/metadata|persist|qmcs" $W/rd/fstab.test
! grep -E "formattable|userdata" $W/rd/fstab.test $W/rd/first_stage_ramdisk/fstab.default || { echo "unsafe fstab"; exit 1; }

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
$MK "${args[@]}" --cmdline "$BOOTARGS" --output $W/boot-aospa.img
echo "modules.load: $(wc -l < $MD/modules.load), first: $(head -3 $MD/modules.load | tr '\n' ' ')"
ls -la $W/boot-aospa.img; sha256sum $W/boot-aospa.img
