#!/bin/bash
# Validate lemonadep's Lahaina base dtbs and overlay dtbos for the 6.18 kernel.
set -e

R=${R:-$HOME/r618}
DT=${DT:-$R/lemonadep-6.18-devicetrees}
K=${K:-$R/lemonadep-6.18-kernel}
O=${O:-$R/out-dt}
DTC=${DTC:-$R/out/scripts/dtc/dtc}
FDT_OVERLAY=${FDT_OVERLAY:-$R/out/scripts/dtc/fdtoverlay}
CC=${CC:-${CLANG:+$CLANG/clang}}
CC=${CC:-$HOME/tc/clang-r596125/bin/clang}
BASE_DTBS=("qcom/lahaina.dts" "qcom/lahaina-v2.dts" "qcom/lahaina-v2.1.dts")
OVERLAYS=("qcom/lemonadep-overlay.dtso" "qcom/lemonadep-t0-overlay.dtso")

mkdir -p "$O"
pp() {
	"$CC" -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -P \
		-I "$DT/qcom" -I "$DT/bindings" -I "$DT/include" -I "$DT" \
		-I "$K/include" -I "$K/arch/arm64/boot/dts" -I "$K/scripts/dtc/include-prefixes" \
		-o "$2" "$1"
}

bases=()
for base_dts in "${BASE_DTBS[@]}"; do
	name=$(basename "$base_dts" .dts)
	pp "$DT/$base_dts" "$O/$name.pp"
	"$DTC" -@ -q -I dts -O dtb -o "$O/$name.dtb" "$O/$name.pp"
	bases+=("$name")
done

outputs=()
for overlay in "${OVERLAYS[@]}"; do
	name=$(basename "$overlay" .dtso)
	pp "$DT/$overlay" "$O/$name.pp"
	"$DTC" -@ -q -I dts -O dtb -o "$O/$name.dtbo" "$O/$name.pp"
	outputs+=("$O/$name.dtbo")
	for base in "${bases[@]}"; do
		"$FDT_OVERLAY" -i "$O/$base.dtb" -o "$O/$base-$name.dtb" "$O/$name.dtbo"
	done
done

# The production OnePlus 9 Pro base is Lahaina v2.1, but every overlay is
# validated against all three stock bases as the OPLUS makefile did.
ls -la "$O/lahaina-v2.1.dtb" "${outputs[@]}"
