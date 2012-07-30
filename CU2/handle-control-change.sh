#! /bin/sh

. ./common.inc

touch "${STATES_DIR}/updating"
if [ -e "$DNSCRYPT_FILE" ]; then
  ./switch-to-dnscrypt.sh
else
  ./stop-dnscrypt-proxy.sh
  ./switch-to-dhcp.sh
fi
rm -f "${STATES_DIR}/updating"
rm -f "${STATES_DIR}/update-request"

