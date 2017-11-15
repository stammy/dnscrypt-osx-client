#! /bin/sh

. ./common.inc

[ -e "$DNSCRYPT_FILE" ] && exit 0

./exceptions-remove.sh
exec ./set-dns-to-dhcp.sh
