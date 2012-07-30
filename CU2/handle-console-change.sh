#! /bin/sh

. ./common.inc

eval $(stat -s /dev/console) || exit 1
mkdir -p "$DNSCRYPT_BASE_DIR" || exit 1
chown -R 0:0 "$DNSCRYPT_BASE_DIR"
chown -R "${st_uid}:0" "$CONTROL_DIR"
find "$DNSCRYPT_BASE_DIR" -type d -exec chmod 755 {} \;

