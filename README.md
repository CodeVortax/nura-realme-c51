# Nura on Realme C51 (RMX3830)

Work-in-progress port of **Nura** (formerly postmarketOS, renamed in September 2026) to the
**Realme C51 / RMX3830** (Unisoc T612 family, board `ums9230_hulk`).

> Status: **experimental, nothing has booted yet.** See [docs/STATUS.md](docs/STATUS.md)
> for what is confirmed and what is still a guess.

## Approach

- Keep the **stock 5.15 GKI-style kernel** (`5.15.189-android13-8`) taken from the device's own `boot` partition.
- The vendor drivers (clock, PMIC, eMMC, touch, display, USB) are `.ko` files inside the stock `vendor_boot` ramdisk,
  so the Nura initramfs only needs to run `insmod` in the vendor's own order (`modules.load.recovery`).
- Replace only `init_boot` with a Nura/Alpine initramfs; leave `vendor_boot` untouched.
- Install on slot **A** and keep Android on slot **B** as the fallback.
- First milestone is not a GUI: **USB NCM + telnet on `172.16.42.1`** and kernel log lines prefixed `nura:`.

## Repo layout

| Path | What |
|---|---|
| `docs/DEVICE.md` | Hardware/partition facts collected from the device |
| `docs/STATUS.md` | Confirmed vs. unknown |
| `docs/BUILD.md` | Dump, build, flash, recover |
| `tools/dump-device.sh` | Collects boot images and module lists (root, run on the phone) |
| `tools/build-init-boot.sh` | Builds the test `init_boot` image + patched `vbmeta` |
| `tools/initramfs/init` | Minimal init: loads modules, brings up USB NCM + telnet |
| `pmaports/` | Skeleton `device-realme-rmx3830` and `linux-realme-rmx3830` packages |

## Not in this repo

Stock images, `.ko` modules and firmware are proprietary and are **not** committed (`.gitignore`).
You must dump them from your own device with `tools/dump-device.sh`.

## Warning

Flashing can brick your device. Back up every partition you touch. Do not switch the active slot
without a way to run `fastboot set_active b`.
