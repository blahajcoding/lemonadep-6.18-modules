# redwood 6.18 modules

The vendor and out-of-tree kernel modules for the **Redmi Note 12 Pro 5G /
POCO X5 Pro 5G** (`redwood`, SM7325) on Linux 6.18. It covers the Qualcomm
techpack drivers (display, GPU, audio, camera, Wi-Fi, mobile data,
TrustZone) and redwood's own board drivers, ported to build against
[redwood-6.18-kernel](https://github.com/suvojeet-sengupta/redwood-6.18-kernel).

Together with the in-tree modules, this makes up the 311 modules the
[prebuilt](https://github.com/suvojeet-sengupta/device_xiaomi_redwood-kernel-6.18)
ships: 238 in-tree and 73 from here.

## Layout

| Directory | Modules | What it is |
|---|---|---|
| `display-drivers` | `msm_drm` | Snapdragon display (SDE/DSI), M20 panel |
| `graphics-kernel` | `msm_kgsl` | Adreno 642L GPU (KGSL) |
| `mm-drivers` | `msm_ext_display` | External display glue for display and audio |
| `audio-kernel` | `machine_dlkm`, `q6_dlkm`, `bolero_cdc_dlkm`, `wcd938x_dlkm`, `wsa883x_dlkm`, … (30) | lahaina/yupik audio: ADSP (Q6/APR), Bolero macros, WCD codecs, SoundWire |
| `camera-kernel` | `camera` | Spectra (Titan 570) camera, including LRME |
| `securemsm-kernel` | `qseecom_dlkm`, `smcinvoke_dlkm`, `qce50_dlkm`, `qcedev-mod_dlkm`, `qcrypto-msm_dlkm`, `qrng_dlkm`, `hdcp_qseecom_dlkm`, `smmu_proxy_dlkm` | TrustZone clients and crypto engine |
| `wlan` | `wlan` (qcacld-3.0), `icnss2`, `cnss_*`, `wlan_firmware_service` | WCN6750 Wi-Fi |
| `dataipa` | `ipam`, `ipanetm`, `gsim` | IPA hardware offload |
| `datarmnet`, `datarmnet-ext` | `rmnet_core`, `rmnet_ctl`, `rmnet_mem` | rmnet mobile data |
| `nfc-driver` | `nxp-nci` | NXP NFC |
| `redwood` | 18 modules, see below | redwood's board drivers |
| `bringup` | — | Build and packing scripts, plus the 6.18 bring-up tools |

The Qualcomm trees came over from the redwood 6.12 kernel's `vendor/`, which
in turn comes from CodeLinaro. They're changed only where 6.18 needs it.
Each commit says what changed and why.

### redwood drivers

| Module | Hardware |
|---|---|
| `goodix_berlin_core`, `goodix_berlin_spi` | Goodix Berlin-D touch (the mainline driver) with double tap to wake |
| `focaltech_touch`, `xiaomi_touch` | Focaltech touch and Xiaomi's touch feature interface |
| `snd-soc-aw88261`, `snd-soc-aw88395-lib` | AW88261 smart speaker amps (mainline driver), with Xiaomi's controls |
| `aw8697-haptic` | AW8697 haptics |
| `goodix_fp`, `xiaomi_fp` | Fingerprint |
| `msm-vidc` | Video codecs: lahaina msm_vidc, the V4L2 ABI the vendor Codec2 uses |
| `frpc-adsprpc` | Legacy FastRPC (`/dev/adsprpc-smd`), needed by the vendor's libadsprpc |
| `btpower`, `bt_fm_slim` | WCN6750 Bluetooth power and the FM/BT SLIMbus link |
| `ir-spi` | IR blaster |
| `mi_thermal` | Xiaomi thermal interface |
| `subsys_compat`, `ioncompat` | Shims for the 5.4-era interfaces the vendor userspace uses |
| `usbrole` | Keeps the USB controller's role right while UCSI on the ADSP reports nothing |
| `bootlog`, `logcap`, `testguard` | Bring-up only: kernel and Android log to `logdump`, and a userdata guard for test boots. Not shipped |

[redwood/README.md](redwood/README.md) explains each one in detail.

## Building

The scripts in `bringup/` build everything against a configured and built
kernel tree. By default they expect this layout under `R` (`~/r618`):

```
$R/redwood-6.18-kernel   kernel source
$R/out                   kernel build (O=), after "Image modules"
$R/redwood-6.18-modules  this repository
$R/vb                    work directory for the module builds
```

Set `R` for another location, and `CLANG` for the Clang `bin` directory
(default `~/tc/clang-r596125/bin`):

```sh
export R=~/r618 PAHOLE=<pahole>
B=$R/redwood-6.18-modules/bringup
bash $B/build-vendor618.sh    # mm-drivers, display, GPU, securemsm, audio
bash $B/build-data618.sh      # rmnet_mem, IPA, rmnet
bash $B/build-wlan618.sh      # WCN6750 platform drivers, qcacld-3.0
bash $B/build-misc618.sh      # NFC, camera
bash $B/build-redwood618.sh   # redwood drivers
```

Each tree builds in its own copy under `$R/vb`, with its log next to it.
Each script prints a return code and error count per tree. The `.ko` files
end up in `$R/vb/<tree>`. Strip them with `llvm-strip --strip-debug` before
they go into a ramdisk.

Notes:
- **Vermagic is strict.** Rebuild every module whenever the kernel version changes.
- **Ignore `sync_fence` and `hw_fence` failures.** They're part of `mm-drivers` but not used on yupik, so they're expected to fail.
- **datarmnet needs `CONFIG_IPA3`.** Without it, it links against the IPA stubs and every `rmnet_data` link fails with -ENOMEM. The script sets it.
- **Out-of-tree trees don't pass `out/Module.symvers` in `KBUILD_EXTRA_SYMBOLS`.** modpost already reads it through `O=`.

## Bring-up tools

`bringup/` also holds the tools used to bring 6.18 up on redwood:
- A minimal init with a USB serial shell (`shell618.c`, `rsh618.py`)
- A first-stage module loader (`modload618.c`)
- Packing scripts:
  - `pack-bringup618.sh`: bring-up images
  - `pack-aospa618.sh`: AOSPA RAM boots
  - `pack-daily618.sh`: a boot image for a slot's own system
- Source converters: `ddk2kbuild.py`, `audiokbuild.py` and `lvc618.py` turn Qualcomm's Bazel/DDK lists and kernel version conditionals into plain Kbuild

## License

GPL-2.0, like the drivers themselves. Each tree keeps its own license
headers.

Ported and maintained by Suvojeet Sengupta.
