#!/bin/sh
# Usage: sh tools/nura-slot.sh status | try | restore     (run as the Termux user; uses sudo)
# Edits only the 32-byte AOSP bootloader_control block at misc offset 2048, plus slot A partitions.
# Android keeps running from slot B. 'try' makes A the preferred slot with ONE try (not marked successful).
set -e
MISC=${MISC:-/dev/block/by-name/misc}
BN=${BN:-/dev/block/by-name}
W=${W:-$HOME/nura}
BAK=${BAK:-/sdcard}
KERNEL_IMG=${KERNEL_IMG:-$BAK/boot_b.img}        # stock boot image (5.15.189) dumped from slot B
INIT_IMG=${INIT_IMG:-$W/init_boot_nura.img}
SUDO=${SUDO-sudo}
mkdir -p "$W"

rd() { $SUDO dd if="$MISC" of="$W/bc.bin" bs=1 skip=2048 count=32 2>/dev/null; }
py() { python3 - "$@" <<'PY'
import sys, zlib, struct
mode, f = sys.argv[1], sys.argv[2]
b = bytearray(open(f, 'rb').read())
assert len(b) == 32 and b[4:8] == b'BCAB', "not a BCAB block"
def info(i):
    v = b[12 + 2*i]
    return dict(prio=v & 15, tries=(v >> 4) & 7, ok=(v >> 7) & 1)
crc_ok = (zlib.crc32(bytes(b[:28])) & 0xffffffff) == struct.unpack('<I', b[28:32])[0]
if mode == 'show':
    print("crc ok:", crc_ok)
    for i in (0, 1): print("slot", "AB"[i], info(i))
    sys.exit(0 if crc_ok else 1)
assert crc_ok, "CRC mismatch, refusing"
if mode == 'prefer_a':
    b[12] = 0x0f | (1 << 4)           # A: prio 15, tries 1, not successful
    b[14] = (b[14] & 0xf0) | 14       # B: prio 14, keep tries/successful bits
b[28:32] = struct.pack('<I', zlib.crc32(bytes(b[:28])) & 0xffffffff)
open(f + '.new', 'wb').write(b)
PY
}
wr() { $SUDO dd if="$W/bc.bin.new" of="$MISC" bs=1 seek=2048 conv=notrunc 2>/dev/null; sync; }

case "$1" in
status)
  rd; py show "$W/bc.bin" ;;
try)
  for f in "$KERNEL_IMG" "$INIT_IMG"; do [ -s "$f" ] || { echo "missing $f"; exit 1; }; done
  for p in boot_a init_boot_a vendor_boot_a; do [ -s "$BAK/bak_$p.img" ] || { echo "missing backup $BAK/bak_$p.img"; exit 1; }; done
  [ -s "$BAK/bak_misc.img" ] || $SUDO dd if="$MISC" of="$BAK/bak_misc.img" 2>/dev/null
  rd; py show "$W/bc.bin"; cp "$W/bc.bin" "$W/bc.orig"
  echo "Will write boot_a (stock kernel) + init_boot_a (Nura) and prefer slot A for ONE try."
  printf "Type YES to continue: "; read a; [ "$a" = YES ] || exit 1
  $SUDO dd if="$KERNEL_IMG" of="$BN/boot_a" 2>/dev/null
  $SUDO dd if="$INIT_IMG" of="$BN/init_boot_a" 2>/dev/null
  sync
  $SUDO cmp -n "$(stat -c %s "$KERNEL_IMG")" "$KERNEL_IMG" "$BN/boot_a"
  $SUDO cmp -n "$(stat -c %s "$INIT_IMG")" "$INIT_IMG" "$BN/init_boot_a"
  py prefer_a "$W/bc.bin"; wr; rd; py show "$W/bc.bin"
  echo "Done. Reboot to try Nura. If it hangs: long-press power to reboot; expected fallback to B." ;;
restore)
  for p in boot_a init_boot_a; do $SUDO dd if="$BAK/bak_$p.img" of="$BN/$p" 2>/dev/null; done
  [ -s "$W/bc.orig" ] && $SUDO dd if="$W/bc.orig" of="$MISC" bs=1 seek=2048 conv=notrunc 2>/dev/null
  sync; rd; py show "$W/bc.bin" ;;
*) echo "usage: $0 status|try|restore"; exit 1 ;;
esac
