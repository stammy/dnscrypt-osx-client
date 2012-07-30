#! /bin/sh

. ./common.inc

if [ -e "$DNSCRYPT_FILE" ]; then
  exec ./switch-to-dnscrypt.sh
else
  ./stop-dnscrypt-proxy.sh
  exec ./switch-to-dhcp.sh
fi
