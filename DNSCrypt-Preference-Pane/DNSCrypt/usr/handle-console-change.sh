#! /bin/sh

. ./common.inc

eval $(stat -s '/dev/console') || exit 1
wanted_uid="$st_uid"
if [ ! -d "$DNSCRYPT_VAR_BASE_DIR" ]; then
  mkdir -p "$DNSCRYPT_VAR_BASE_DIR" || exit 1
  chown -R 0:0 "$DNSCRYPT_VAR_BASE_DIR"
fi
mkdir -p "$TICKETS_DIR" || exit 1
eval $(stat -s "$CONTROL_DIR") || exit 1
chown -R "${wanted_uid}:0" "$CONTROL_DIR"
find "$DNSCRYPT_VAR_BASE_DIR" -type d -exec chmod 755 {} \;
