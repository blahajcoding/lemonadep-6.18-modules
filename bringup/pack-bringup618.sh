#!/bin/bash
# Bring-up images for 6.18 on redwood, built from a slot's own boot and
# vendor_boot: the 6.18 Image with a ramdisk that only holds the modload
# init and the first stage modules, the slot's vendor_boot with the 6.18 base
# dtb, and a dtbo.img with the 6.18 redwood overlay. The init never mounts
# /data; it saves the kernel log to logdump and reboots to the bootloader.
# Usage: pack-bringup618.sh <boot.img> <vendor_boot.img>
set -e
BOOT=${1:?boot.img}; VBOOT=${2:?vendor_boot.img}
R=~/r618; O=$R/out; T=$R/tools; W=$R/pack; DT=$R/out-dt
export PATH=$HOME/tc/clang-r596125/bin:$PATH
UNPACK="python3 $T/unpack_bootimg"; MK="python3 $T/mkbootimg/mkbootimg.py"
REL=$(cat $O/include/config/kernel.release)

rm -rf $W; mkdir -p $W
$UNPACK --boot_img $BOOT --out $W/b >/dev/null
$UNPACK --boot_img $VBOOT --out $W/vb >/dev/null

# Modules: stripped, signed by the build, into a staging tree
make -s -C $R/redwood-6.18-kernel O=$O ARCH=arm64 LLVM=1 LLVM_IAS=1 LOCALVERSION= \
	INSTALL_MOD_PATH=$W/stage INSTALL_MOD_STRIP=1 modules_install
M=$W/stage/lib/modules/$REL

# First stage list: the slot's own modules.load, minus what 6.18 doesn't build
mkdir -p $W/vr
(cd $W/vr && lz4 -dc $W/vb/vendor_ramdisk00 2>/dev/null | cpio -id --quiet) ||
	(cd $W/vr && lz4 -dc $W/vb/vendor_ramdisk | cpio -id --quiet)
LOAD=$W/vr/lib/modules/modules.load
[ -f $LOAD ] || { echo "no lib/modules/modules.load in the vendor ramdisk"; exit 1; }
find $M -name "*.ko" > $W/all.txt

# Ramdisk: init + modules flat in lib/modules/<release>
RD=$W/rd; MD=$RD/lib/modules/$REL
mkdir -p $MD $RD/dev $RD/proc $RD/sys
cp ${INIT:-$R/bringup/init} $RD/init; chmod 755 $RD/init
: > $W/missing.txt; : > $MD/modules.load
while read -r m; do
	f=$(grep -m1 "/$m$" $W/all.txt || true)
	if [ -n "$f" ]; then
		cp "$f" $MD/
		echo "$m" >> $MD/modules.load
	else
		echo "$m" >> $W/missing.txt
	fi
done < <(grep -vxF -e qcom_wdt_core.ko -e qcom_soc_wdt.ko $LOAD | head -n ${LIMIT:-100000})
for m in $EXTRA; do f=$(grep -m1 "/$m$" $W/all.txt || true); [ -n "$f" ] && { cp "$f" $MD/; echo "$m" >> $MD/modules.load; }; done
# VENDOR: a directory of out-of-tree modules to carry in the ramdisk (not
# auto-loaded; the shell's modprobe and loadall can load them)
if [ -n "$VENDOR" ]; then cp $VENDOR/*.ko $MD/; fi
# Pull in every dependency the listed modules need, from the full modules.dep
# modules_install wrote (a depmod over the copied subset can't name providers
# it doesn't have)
python3 - "$M/modules.dep" "$MD" <<'PY'
import os, shutil, sys
dep, md = sys.argv[1], sys.argv[2]
root = os.path.dirname(dep)
deps, path = {}, {}
for line in open(dep):
    k, _, v = line.partition(":")
    b = os.path.basename(k)
    path[b] = os.path.join(root, k)
    deps[b] = [os.path.basename(x) for x in v.split()]
todo = [f for f in os.listdir(md) if f.endswith(".ko")]
seen = set()
while todo:
    m = todo.pop()
    if m in seen:
        continue
    seen.add(m)
    if m not in path:
        if os.path.exists(os.path.join(md, m)):
            # out-of-tree module: follow its in-tree dependencies too
            import subprocess
            d = subprocess.run(["/sbin/modinfo", "-F", "depends", os.path.join(md, m)],
                               capture_output=True, text=True).stdout.strip()
            alias = {k.replace("-", "_"): k for k in path}
            alias.update({f.replace("-", "_"): f for f in os.listdir(md)})
            todo += [alias.get(x.replace("-", "_") + ".ko", x + ".ko") for x in d.split(",") if x]
            continue
        sys.exit("dependency %s not built" % m)
    drop = set(os.environ.get("DROP", "").split())
    def needs_drop(x, seen2=None):
        seen2 = seen2 or set()
        if x in drop: return True
        for d in deps.get(x, []):
            if d not in seen2:
                seen2.add(d)
                if needs_drop(d, seen2): return True
        return False
    if drop and needs_drop(m):
        p2 = os.path.join(md, m)
        if os.path.exists(p2): os.remove(p2)
        print("dropped", m)
        continue
    if not os.path.exists(os.path.join(md, m)):
        shutil.copy(path[m], md)
    todo += deps.get(m, [])
PY
S=$W/dep/lib/modules/$REL; rm -rf $W/dep; mkdir -p $S; cp $MD/*.ko $S/
depmod -b $W/dep $REL 2>/dev/null
# keep modules.load to what is in the ramdisk
grep -xF -f <(ls $MD | grep "\.ko$") $MD/modules.load > $MD/modules.load.new; mv $MD/modules.load.new $MD/modules.load
# loadall list: everything except what still takes the SoC down on 6.18
# (CoreSight resets the SoC, the LPM governor panics)
grep -vE "^(coresight.*|qcom_lpm)\\.ko$" $MD/modules.load > $MD/modules.all; if [ -n "$VENDOR" ]; then (cd $VENDOR && ls *.ko) >> $MD/modules.all; fi; if [ -n "$LOADLIST" ]; then grep -xF -f <(ls $MD | grep "\.ko$") $LOADLIST > $MD/modules.load; fi
# modules.dep with bare names, as modload wants them
sed -E "s#[^ :]*/##g" $S/modules.dep > $MD/modules.dep
if [ -n "$NOLOAD" ]; then rm -f $MD/*.ko; : > $MD/modules.load; : > $MD/modules.dep; echo "NOLOAD: no modules in the ramdisk"; fi
echo "first stage: $(wc -l < $MD/modules.load) listed, $(ls $MD/*.ko | wc -l) with dependencies," \
	"$(wc -l < $W/missing.txt) of the slot's not built for 6.18"
(cd $RD && find . | LC_ALL=C sort | cpio -o -H newc -R 0:0 --quiet) | lz4 -l -12 --favor-decSpeed -q > $W/ramdisk.lz4

# vendor_boot: the slot's own, with the 6.18 base dtb
VARGS=$($UNPACK --boot_img $VBOOT --out $W/vb --format=mkbootimg)
eval "set -- $VARGS"
args=(); while [ $# -gt 0 ]; do
	case "$1" in
	--dtb) args+=("$1" "${DTB:-$DT/yupik.dtb}"); shift 2 ;;
	--vendor_boot) shift 2 ;;
	*) args+=("$1"); shift ;;
	esac
done
$MK "${args[@]}" --vendor_boot $W/vendor_boot.img

# boot: 6.18 Image and the bring-up ramdisk, the slot's header and cmdline
BARGS=$($UNPACK --boot_img $BOOT --out $W/b --format=mkbootimg)
eval "set -- $BARGS"
args=(); while [ $# -gt 0 ]; do
	case "$1" in
	--kernel) args+=("$1" "${KIMG:-$O/arch/arm64/boot/Image}"); shift 2 ;;
	--ramdisk) args+=("$1" "$W/ramdisk.lz4"); shift 2 ;;
	--output|-o) shift 2 ;;
	*) args+=("$1"); shift ;;
	esac
done
$MK "${args[@]}" --output $W/boot.img

python3 $T/mkdtboimg create $W/dtbo.img $DT/redwood-overlay.dtbo

strings $W/b/kernel | grep -m1 "^Linux version" | cut -c1-60
strings $O/arch/arm64/boot/Image | grep -m1 "^Linux version" | cut -c1-60
ls -la $W/boot.img $W/vendor_boot.img $W/dtbo.img
sha256sum $W/boot.img $W/vendor_boot.img $W/dtbo.img
