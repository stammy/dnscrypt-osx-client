#! /bin/sh

. ./common.inc

rm -f "$DNSCRYPT_FILE"
exec ./switch-to-dhcp-if-required.sh
