# Device facts (RMX3830)

| Item | Value |
|---|---|
| Board | `ums9230_hulk` (androidboot.hardware) |
| Kernel | `5.15.189-android13-8-ga491ad257e4b-ab81` |
| Firmware | Android 15 |
| Partitioning | A/B, dynamic partitions (`super`) |
| Storage | eMMC on `soc/soc:ap-apb/201d0000.sdio` (driver `sdhci-sprd`) |
| Display | 720x1600, panel `lcd_ft8057p_s_ld_mipi_hd`, parameters passed by the bootloader via cmdline (`lcd_*`) |
| Touch | likely `focaltech_touch-modules` (not verified) |
| PMIC | SC2730 |
| GPU | Mali (`mali_kbase.ko`, proprietary, lives in `vendor_dlkm`) |
| Wi-Fi/BT | `unisoc_wcn_bsp`, `sprd_wlan_combo`, `cfg80211` (in `vendor_dlkm`) |
| Debug UART | `console=ttyS1,921600n8` in the stock cmdline |
| Watchdog | enabled by the bootloader (`sprdboot.wdten`) |

## Boot images (all header version 4)

- `boot`: kernel only (~47 MB Image), no ramdisk
- `init_boot`: 8 MiB partition, stock ramdisk ~3 MB (LZ4)
- `vendor_boot`: ramdisk ~36 MB (contains the recovery-style tree and `lib/modules`), dtb ~131 KB
  - page size `0x1000`, kernel load `0x8000`, ramdisk load `0x5400000`, tags `0x100`, dtb `0x1f00000`
  - vendor cmdline: `console=ttyS1,115200n8 bootconfig`
  - Offsets above are the load addresses reported by `unpack_bootimg`; base is assumed 0.

## Kernel config (from /proc/config.gz)

Built in: EXT4, F2FS, EROFS, FUSE, OVERLAY_FS, TMPFS, CONFIGFS_FS, USB_CONFIGFS, USB_LIBCOMPOSITE,
USB_F_NCM, USB_F_FS, PSTORE, PSTORE_RAM, CGROUPS, NAMESPACES.
Not reported: DEVTMPFS, framebuffer console, USB RNDIS (the init falls back to a tmpfs /dev).

## Slot note

Slot A and B can carry different kernels (A may hold a custom kernel). Use the kernel from the slot whose
version matches the modules in `vendor_boot`.
