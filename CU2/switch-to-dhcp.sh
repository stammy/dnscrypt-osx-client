#! /bin/sh

. common.inc

[ -e "$DNSCRYPT_FILE" ] && exit 0

./set-dns-to-dhcp.sh
