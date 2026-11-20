#!/system/bin/sh
# Run on the phone as root (Termux: sudo sh tools/dump-device.sh). Reads only, writes to ./dumps
set -e
OUT=${1:-dumps}
mkdir -p "$OUT"
SFX=$(getprop ro.boot.slot_suffix)
for p in boot init_boot vendor_boot vbmeta dtbo; do
  for s in _a _b; do
    dd if=/dev/block/by-name/${p}${s} of="$OUT/${p}${s}.img" 2>/dev/null || echo "skip ${p}${s}"
  done
done
{
  echo "slot: $SFX"
  uname -r
  getprop ro.product.board
  getprop ro.build.version.release
  # serial numbers and ids are filtered out on purpose
  cat /proc/bootconfig | grep -viE "serial|chipid|nv_id"
  cat /proc/cmdline | tr ' ' '\n' | grep -viE "serial|id="
  zcat /proc/config.gz | grep -E "CONFIG_(EXT4_FS|F2FS_FS|EROFS_FS|CONFIGFS_FS|USB_CONFIGFS|USB_F_RNDIS|USB_F_NCM|PSTORE|PSTORE_RAM|DEVTMPFS|FB)="
  cat /vendor_dlkm/lib/modules/modules.load
} > "$OUT/device-info.txt" 2>&1
echo "done: $OUT"
