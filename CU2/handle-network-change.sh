#! /bin/ksh

. common.inc

FALLBACK_FILE="${CONTROL_DIR}/fallback"

[ ! -e "$FALLBACK_FILE" ] && exit 0
./check-network-change.sh || exit 0
./check-hijacking.sh && exit 0
./set-dns-to-dhcp.sh
./switch-to-dnscrypt.sh
