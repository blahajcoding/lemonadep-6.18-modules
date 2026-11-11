#!/bin/bash
# Build redwood's base dtb (yupik.dtb) and overlay dtbo for the 6.18 kernel.
set -e
R=~/r618
DT=$R/redwood-6.18-devicetrees
K=$R/redwood-6.18-kernel
O=$R/out-dt
DTC=$R/out/scripts/dtc/dtc
CC=$HOME/tc/clang-r596125/bin/clang
mkdir -p $O
pp() {
	$CC -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -P \
		-I $DT/qcom -I $DT/bindings -I $DT/include -I $DT \
		-I $K/include -I $K/arch/arm64/boot/dts -I $K/scripts/dtc/include-prefixes \
		-o "$2" "$1"
}
pp $DT/qcom/yupik.dts $O/yupik.pp
$DTC -@ -q -I dts -O dtb -o $O/yupik.dtb $O/yupik.pp
pp $DT/qcom/redwood-overlay.dtso $O/redwood-overlay.pp
$DTC -@ -q -I dts -O dtb -o $O/redwood-overlay.dtbo $O/redwood-overlay.pp
ls -la $O/yupik.dtb $O/redwood-overlay.dtbo
