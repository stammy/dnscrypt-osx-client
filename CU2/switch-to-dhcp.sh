#! /bin/sh

. common.inc

DNSCRYPT_FILE="${CONTROL_DIR}/dnscrypt"

[ -e "$DNSCRYPT_FILE" ] && exit 0

./set-dns-to-dhcp.sh
