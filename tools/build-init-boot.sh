#!/bin/sh
# Usage: sh tools/build-init-boot.sh <stock init_boot img> <stock vbmeta img of target slot>
# Needs: curl, tar, cpio, gzip, python3, and AOSP mkbootimg (set MKBOOTIMG=/path/to/mkbootimg.py)
set -e
MKBOOTIMG=${MKBOOTIMG:-$HOME/mkbootimg/mkbootimg.py}
VBMETA=${2:?vbmeta image}
mkdir -p work/rd work/bb
cd work
URL=https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/aarch64
B=$(curl -s $URL/ | grep -o 'busybox-static-[0-9][^"]*\.apk' | head -1)
curl -sO "$URL/$B"
tar -xzf "$B" -C bb 2>/dev/null
cp bb/bin/busybox.static rd/busybox && chmod 755 rd/busybox
cp ../tools/initramfs/init rd/init
# vendor modules come from the stock vendor_boot ramdisk, not from this image
( cd rd && find . | cpio -o -H newc -R 0:0 2>/dev/null | gzip -9 > ../ramdisk.gz )
python3 "$MKBOOTIMG" --header_version 4 --ramdisk ramdisk.gz -o init_boot_nura.img
python3 - "$VBMETA" <<'PY'
import sys
d=bytearray(open(sys.argv[1],'rb').read()); assert d[:4]==b'AVB0'
d[120:124]=(3).to_bytes(4,'big')   # disable verity + verification
open('vbmeta_a_patched.img','wb').write(d)
PY
ls -l init_boot_nura.img vbmeta_a_patched.img
