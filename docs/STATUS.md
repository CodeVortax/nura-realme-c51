# Status

## Confirmed (read from a real device)
- Kernel version, board name, A/B + dynamic partitions, eMMC controller path
- Boot image header versions, load addresses, sizes
- Module list and load order (`modules.load.recovery` in `vendor_boot`)
- Kernel options listed in DEVICE.md
- Bootloader unlocked (`verifiedbootstate=orange`)

## Built but untested
- Test `init_boot` (busybox + `tools/initramfs/init`)
- `vbmeta` copy with verification disabled (flags = 3)

## Unknown / open
- Whether the bootloader merges the `init_boot` ramdisk with the `vendor_boot` ramdisk the way stock Android does
  (the plan depends on it)
- Whether the bootloader falls back to the other slot after failed boots
- How `pmbootstrap` should flash `init_boot` (needs a `deviceinfo` flash method / manual `fastboot flash init_boot`)
- GPU (Mali, proprietary): software rendering expected
- Modem, camera, audio: out of scope for first boot
- Display output before the DRM driver loads: no framebuffer console is guaranteed

## Not possible yet
- Switching active slot without a PC (`fastboot set_active`)

## Findings from the stock bootloader log (uboot_log)
- Generic ramdisk in `boot` is empty; the bootloader loads `init_boot` (3110766 B) plus the vendor ramdisk (36140521 B).
- Bootloader unlocked: boot image verification skipped, AVB errors allowed. Current `init_boot` already fails verify (0x3) and still boots.
- A/B metadata is AOSP `BCAB` at `misc` offset 2048: A prio 14 tries 1 successful 0, B prio 15 tries 1 successful 1 (booted B).
- Kernel config: no DEVTMPFS, FB, USER_NS or CGROUP_PIDS; DRM present, no fbcon. NCM/ECM/ACM gadget functions present.
- Unverified: whether the bootloader decrements `tries_remaining` (automatic fallback to the other slot).
