#!/bin/bash
# Build lemonadep's mobile data stack (rmnet_mem, IPA, rmnet) against the 6.18
# kernel in ~/r618/out, from Qualcomm's Bazel module lists via ddk2kbuild.py.
R=${R:-$HOME/r618}; K=$R/lemonadep-6.18-kernel; O=$R/out; V=$R/lemonadep-6.18-modules; W=$R/vb; B=$V/bringup
export PATH=${CLANG:-$HOME/tc/clang-r596125/bin}:$PATH
MK="make -C $K O=$O ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION= ${PAHOLE:+PAHOLE=$PAHOLE} -j${JOBS:-$(nproc)}"
check_rc() {
	local rc=$1 name=$2 log=$3
	echo "$name rc=$rc"
	if [ "$rc" -ne 0 ]; then
		echo "error: $name failed; see $log" >&2
		exit "$rc"
	fi
}
G="python3 $B/ddk2kbuild.py"
LAH="--set CONFIG_ARCH_LAHAINA=y"

rsync -a --delete $V/datarmnet-ext/mem/ $W/rmnet_mem/ || exit 1
$G $W/rmnet_mem $W/rmnet_mem/define_mem.bzl 'define_mem("lahaina", "perf")' $LAH || exit 1
$MK M=$W/rmnet_mem modules > $W/rmnet_mem.log 2>&1; check_rc $? rmnet_mem $W/rmnet_mem.log

rsync -a --delete $V/dataipa/ $W/dataipa/ || exit 1
D='$(src)/drivers/platform/msm'
$G $W/dataipa $W/dataipa/define_modules.bzl 'define_modules("lahaina", "perf")' $LAH \
	--conf $W/dataipa/config/dataipa_GKI.conf --set CONFIG_IPA_RMNET_MEM=y --only gsim --only ipam --only ipanetm \
	--cflags "-include \$(src)/config/dataipa_vendor.h -I$D/include -I$D/include/linux -I$D/include/uapi -I$D/gsi -I$D/gsi/gsihal -I$D/ipa -I$D/ipa/ipa_v3 -I$D/ipa/ipa_v3/ipahal -I$D/ipa/ipa_clients -I$D/ipa/ipa_v3/dump -I$D/ipa/ipa_v3/dump/ipa5.5 -I$V/datarmnet-ext/mem -I$V/datarmnet/core" || exit 1
$MK M=$W/dataipa KBUILD_EXTRA_SYMBOLS=$W/rmnet_mem/Module.symvers modules > $W/dataipa.log 2>&1; check_rc $? dataipa $W/dataipa.log

rsync -a --delete $V/datarmnet/ $W/datarmnet/ || exit 1
$G $W/datarmnet $W/datarmnet/define_modules.bzl 'define_rmnet_core_module("lahaina", "perf"); define_rmnet_ctl_module("lahaina", "perf")' $LAH --set CONFIG_RMNET_CORE=m --set CONFIG_RMNET_CTL=m --set CONFIG_RMNET_LA_PLATFORM=y --set CONFIG_IPA3=y \
	--cflags "-I\$(src)/core -I$V/dataipa/drivers/platform/msm/include -I$V/dataipa/drivers/platform/msm/include/uapi -I$V/datarmnet-ext/mem" || exit 1
$MK M=$W/datarmnet KBUILD_EXTRA_SYMBOLS="$W/rmnet_mem/Module.symvers $W/dataipa/Module.symvers" modules > $W/datarmnet.log 2>&1
check_rc $? datarmnet $W/datarmnet.log
for f in rmnet_mem dataipa datarmnet; do
	echo "$f: $(grep -c 'error:' $W/$f.log) errors, $(find $W/$f -name '*.ko' | wc -l) modules"
done
