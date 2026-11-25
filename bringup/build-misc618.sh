#!/bin/bash
# camera.ko and NFC are not built by default. camera depends on the deferred
# Qualcomm/Xiaomi charger-flash-backlight chain, and the inherited redwood
# nxp-nci driver is not the lemonadep SN100T/NQ-NCI port. Pass camera-kernel
# or nfc-driver explicitly only while bringing those drivers up.
R=${R:-$HOME/r618}; K=$R/lemonadep-6.18-kernel; O=$R/out; V=$R/lemonadep-6.18-modules; W=$R/vb
export PATH=${CLANG:-$HOME/tc/clang-r596125/bin}:$PATH
MK="make -C $K O=$O ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION= ${PAHOLE:+PAHOLE=$PAHOLE} -j${JOBS:-$(nproc)}"
if [ "$#" -eq 0 ]; then
	echo "camera/nfc deferred; no misc modules built"
	exit 0
fi
for t in "$@"; do
	rsync -a --delete $V/$t/ $W/$t/ || exit 1
	case $t in
	nfc-driver)
		$MK M=$W/nfc-driver CONFIG_NXP_NFC_I2C=m modules > $W/nfc.log 2>&1
		rc=$?; echo "nfc rc=$rc"; [ "$rc" -eq 0 ] || exit "$rc" ;;
	camera-kernel)
		cp $W/camera-kernel/Kbuild.lemonadep $W/camera-kernel/Kbuild; rm -f $W/camera-kernel/Makefile
		$MK M=$W/camera-kernel CAMERA_KERNEL_ROOT=$W/camera-kernel SOC_INCLUDE=$K/include modules > $W/camera.log 2>&1
		rc=$?; echo "camera rc=$rc"; [ "$rc" -eq 0 ] || exit "$rc" ;;
	*)
		echo "error: unknown misc module tree '$t'" >&2
		exit 2 ;;
	esac
done
for f in nfc camera; do
	if [ -f "$W/$f.log" ]; then echo "$f: $(grep -c "error:" $W/$f.log) errors"; fi
done
find $W/nfc-driver $W/camera-kernel -name "*.ko" 2>/dev/null | xargs -r -n1 basename
