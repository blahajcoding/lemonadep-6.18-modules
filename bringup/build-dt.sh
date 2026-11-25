#!/bin/bash
# Validate lemonadep's Lahaina base dtb and overlay dtbos for the 6.18 kernel.
set -e

R=${R:-$HOME/r618}
DT=${DT:-$R/lemonadep-6.18-devicetrees}
K=${K:-$R/lemonadep-6.18-kernel}
O=${O:-$R/out-dt}
DTC=${DTC:-$R/out/scripts/dtc/dtc}
CC=${CC:-${CLANG:+$CLANG/clang}}
CC=${CC:-$HOME/tc/clang-r596125/bin/clang}
BASE_DTS=${BASE_DTS:-qcom/lahaina-v2.1.dts}
OVERLAYS=("qcom/lemonadep-overlay.dtso" "qcom/lemonadep-t0-overlay.dtso")

mkdir -p "$O"
pp() {
	"$CC" -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -P \
		-I "$DT/qcom" -I "$DT/bindings" -I "$DT/include" -I "$DT" \
		-I "$K/include" -I "$K/arch/arm64/boot/dts" -I "$K/scripts/dtc/include-prefixes" \
		-o "$2" "$1"
}

base_name=$(basename "$BASE_DTS" .dts)
pp "$DT/$BASE_DTS" "$O/$base_name.pp"
"$DTC" -@ -q -I dts -O dtb -o "$O/$base_name.dtb" "$O/$base_name.pp"

outputs=("$O/$base_name.dtb")
for overlay in "${OVERLAYS[@]}"; do
	name=$(basename "$overlay" .dtso)
	pp "$DT/$overlay" "$O/$name.pp"
	"$DTC" -@ -q -I dts -O dtb -o "$O/$name.dtbo" "$O/$name.pp"
	outputs+=("$O/$name.dtbo")
done

ls -la "${outputs[@]}"
