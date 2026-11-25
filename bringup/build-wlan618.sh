#!/bin/bash
# Build lemonadep Wi-Fi (PCIe QCA6490) against the 6.18 kernel in ~/r618/out:
# the platform drivers (cnss2, cnss_utils, cnss_nl, cnss_prealloc,
# wlan_firmware_service, cnss_plat_ipc_qmi_svc) and qcacld (wlan.ko,
# profile lahaina_gki_qca6490). redwood's integrated-icnss2 path is not used.
R=${R:-$HOME/r618}; K=$R/lemonadep-6.18-kernel; O=$R/out; V=$R/lemonadep-6.18-modules; W=$R/vb
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
rsync -a --delete $V/wlan/ $W/wlan/ || exit 1
P=$W/wlan/platform
$MK M=$P CONFIG_CNSS2=m CONFIG_CNSS2_QMI=y CONFIG_CNSS_UTILS=m CONFIG_CNSS_GENL=m \
	CONFIG_CNSS_QMI_SVC=m CONFIG_CNSS_PLAT_IPC_QMI_SVC=m CONFIG_CNSS2_SSR_DRIVER_DUMP=y \
	CONFIG_CNSS2_SMMU_DB_SUPPORT=y CONFIG_BUS_AUTO_SUSPEND=y \
	CONFIG_WCNSS_MEM_PRE_ALLOC=m CONFIG_CNSS_OUT_OF_TREE=y \
	KCFLAGS="-I$P/inc -I$P/cnss_utils -I$P/cnss2 -I$P/cnss_prealloc" modules > $W/wlanplat.log 2>&1
check_rc $? "wlan platform" $W/wlanplat.log
[ -s "$P/Module.symvers" ] || { echo "error: wlan platform Module.symvers missing" >&2; exit 1; }
[ "${1:-}" = platform ] && exit 0
Q=$W/wlan/qcacld-3.0
$MK M=$Q WLAN_ROOT=$Q WLAN_PROFILE=lahaina_gki_qca6490 MODNAME=wlan BUILD_DIAG_VERSION=y \
	CONFIG_QCA_CLD_WLAN=m CONFIG_QCA_WIFI_ISOC=0 CONFIG_QCA_WIFI_2_0=1 QCA_WIFI_FTM_NL80211=y \
	KBUILD_EXTRA_SYMBOLS=$P/Module.symvers \
	KCFLAGS="-I$P/inc -I$W/wlan/inc-net -include $Q/configs/kbuild_defines.h -include $Q/configs/config_to_feature.h -include $Q/configs/grep_defines_lahaina.h -Wno-macro-redefined -DWLAN_OPEN_SOURCE -Wno-error=missing-prototypes -Wno-error=unused-variable -Wno-error=unused-but-set-variable" \
	modules > $W/qcacld.log 2>&1
check_rc $? qcacld $W/qcacld.log
for f in wlanplat qcacld; do echo "$f: $(grep -c "error:" $W/$f.log) errors"; done
find $W/wlan -name "*.ko" | xargs -n1 basename
