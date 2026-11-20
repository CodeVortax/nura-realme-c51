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
