#!/bin/bash
# Build lemonadep camera (camera.ko, Titan 570) against the 6.18 kernel in
# ~/r618/out. NFC is not built by default: the inherited redwood nxp-nci
# driver is not the lemonadep SN100T/NQ-NCI port and remains reference-only.
R=${R:-$HOME/r618}; K=$R/lemonadep-6.18-kernel; O=$R/out; V=$R/lemonadep-6.18-modules; W=$R/vb
export PATH=${CLANG:-$HOME/tc/clang-r596125/bin}:$PATH
MK="make -C $K O=$O ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION= ${PAHOLE:+PAHOLE=$PAHOLE} -j${JOBS:-$(nproc)}"
for t in ${*:-camera-kernel}; do
	rsync -a --delete $V/$t/ $W/$t/
	case $t in
	nfc-driver)
		$MK M=$W/nfc-driver CONFIG_NXP_NFC_I2C=m modules > $W/nfc.log 2>&1
		echo "nfc rc=$?" ;;
	camera-kernel)
		cp $W/camera-kernel/Kbuild.lemonadep $W/camera-kernel/Kbuild; rm -f $W/camera-kernel/Makefile
		$MK M=$W/camera-kernel CAMERA_KERNEL_ROOT=$W/camera-kernel SOC_INCLUDE=$K/include modules > $W/camera.log 2>&1
		echo "camera rc=$?" ;;
	esac
done
for f in nfc camera; do echo "$f: $(grep -c "error:" $W/$f.log) errors"; done
find $W/nfc-driver $W/camera-kernel -name "*.ko" | xargs -n1 basename
