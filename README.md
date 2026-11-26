# lemonadep 6.18 modules

Vendor and out-of-tree kernel modules for the **OnePlus 9 Pro** (`lemonadep`,
SM8350/Lahaina) on Android Common Kernel 6.18.

This repository starts from Suvojeet Sengupta's redwood 6.18 module tree
because that tree already ports the closely related Qualcomm Lahaina/Yupik
platform to ACK 6.18. The Qualcomm platform modules are the forward-porting
basis; Xiaomi/redwood board modules are temporary reference material and are
being replaced by OnePlus/OPLUS lemonadep drivers.

**Status: build-system scaffold, not a validated lemonadep module set.**

## Layout

| Directory | Intended lemonadep contents | Current state |
|---|---|---|
| `display-drivers` | Qualcomm SDE/DSI display (`msm_drm`) | Inherited 6.18 port; lemonadep panel integration pending |
| `graphics-kernel` | Adreno GPU (`msm_kgsl`) | Inherited 6.18 port; SM8350 validation pending |
| `mm-drivers` | external display/sync glue | Inherited 6.18 port |
| `audio-kernel` | Qualcomm Lahaina audio platform | Inherited 6.18 port; lemonadep machine/TFA98xx integration pending |
| `camera-kernel` | Spectra camera (`camera.ko`) | Inherited 6.18 port; lemonadep sensor/OIS/DT integration pending |
| `securemsm-kernel` | TrustZone clients and crypto | Inherited 6.18 port |
| `wlan` | QCA6490/CNSS/qcacld Wi-Fi | Inherited Lahaina-profile 6.18 port; validation pending |
| `dataipa`, `datarmnet`, `datarmnet-ext` | IPA/rmnet mobile data | Inherited 6.18 port |
| `nfc-driver` | NFC | Reference only until SN100T/NQ-NCI support is ported |
| `redwood` | Temporary inherited board-driver reference | Contains Xiaomi-specific drivers; not lemonadep support |
| `bringup` | Build and packaging scripts | Being converted to lemonadep |

## Build scripts

The scripts are normally invoked by `lemonadep-6.18-kernel/build.sh`, not run
directly. They expect the work directory to contain or link:

```text
lemonadep-6.18-kernel/
lemonadep-6.18-modules/
lemonadep-6.18-devicetrees/
out/
```

The kernel build creates those links when using a repo-manifest workspace.

`build-vendor618.sh`, `build-data618.sh`, `build-wlan618.sh`,
`build-misc618.sh` and `build-dt.sh` are the supported lemonadep scaffold
entry points. `build-board618.sh`, the `pack-*`/`repack*` scripts, `shell618`,
`modload618`, `logsaver618` and `rsh618` are redwood reference material only;
they are not part of the default lemonadep build and must be re-audited before
use on OnePlus hardware.

## Replacement plan

See [PORTING.md](../lemonadep-6.18-kernel/PORTING.md) in the kernel repository
for the authoritative hardware matrix. In particular, the inherited Xiaomi
touch, fingerprint, speaker, thermal and IR drivers must not be presented as
OnePlus 9 Pro support. They either need removal from the shipped module list
or replacement by the corresponding OPLUS drivers.

No driver is to be silently deleted just because it does not compile. Deferred
hardware must remain documented in the kernel `PORTING.md` matrix and in the
pull request that defers it.
