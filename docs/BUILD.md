# Build / flash / recover

## 1. Dump (on the phone, root)
```
sh tools/dump-device.sh
```
Writes `dumps/` with boot images and module lists. Nothing is flashed.

## 2. Build test images
```
sh tools/build-init-boot.sh dumps/init_boot_b.img dumps/vbmeta_a.img
```
Output: `work/init_boot_nura.img`, `work/vbmeta_a_patched.img`.

## 3. Flash (slot A only, Android stays on B)
Needs a root shell or fastboot:
```
fastboot flash init_boot_a work/init_boot_nura.img
fastboot flash vbmeta_a   work/vbmeta_a_patched.img
fastboot set_active a
```
For slot A to use the matching kernel, write the stock-slot kernel to `boot_a` as well (see STATUS).

## 4. Observe
- `telnet 172.16.42.1` after the phone enumerates a USB NCM gadget
- After returning to Android: `/sys/fs/pstore/console-ramoops-0`, search for `nura:`

## 5. Recover
```
fastboot set_active b
```
Restore slot A from the dumps if needed (`dd` the saved `bak_*_a.img` files back).
