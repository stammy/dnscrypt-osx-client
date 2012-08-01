#! /bin/sh

. ./common.inc

[ ! -e "$FALLBACK_FILE" ] && exit 0
./check-network-change.sh || exit 0

lockfile -1 -r 30 -l 60 "$HANDLERS_LOCK_FILE" || exit 1
./set-dns-to-dhcp.sh
if [ ! -e "$DNSCRYPT_FILE" ]; then
  rm -f "$HANDLERS_LOCK_FILE"
  exit 0
fi
./switch-to-dnscrypt-if-required.sh
rm -f "$HANDLERS_LOCK_FILE"
