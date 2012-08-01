#! /bin/sh

. ./common.inc

touch "${STATES_DIR}/updating"
if [ -e "$DNSCRYPT_FILE" ]; then
  ./switch-to-dnscrypt-if-required.sh
else
  ./stop-dnscrypt-proxy.sh
  ./switch-to-dhcp-if-required-.sh
fi
rm -f "${STATES_DIR}/updating"
rm -f "${STATES_DIR}/update-request"

