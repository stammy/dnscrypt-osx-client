#! /bin/sh

. ./common.inc

[ ! -e "$FALLBACK_FILE" ] && exit 0
./check-network-change.sh || exit 0
./set-dns-to-dhcp.sh
[ ! -e "$DNSCRYPT_FILE" ] && exit 0
./switch-to-dnscrypt-if-required.sh
