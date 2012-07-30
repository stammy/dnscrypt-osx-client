#! /bin/sh

. ./common.inc

eval $(stat -s '/dev/console') || exit 1
wanted_uid="$st_uid"
if [ ! -d "$DNSCRYPT_BASE_DIR" ]; then
  mkdir -p "$DNSCRYPT_BASE_DIR" || exit 1
  chown -R 0:0 "$DNSCRYPT_BASE_DIR"
fi
eval $(stat -s "$CONTROL_DIR") || exit 1
[ "$st_uid" = "$wanted_uid" ] && exit 0
chown -R "${wanted_uid}:0" "$CONTROL_DIR"
find "$DNSCRYPT_BASE_DIR" -type d -exec chmod 755 {} \;
