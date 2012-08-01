#! /bin/sh

. ./common.inc

lockfile "$HANDLERS_LOCK_FILE"

touch "${STATES_DIR}/updating"
if [ -e "$DNSCRYPT_FILE" ]; then
  ./switch-to-dnscrypt-if-required.sh
else
  ./stop-dnscrypt-proxy.sh
  ./switch-to-dhcp-if-required.sh
fi
rm -f "${STATES_DIR}/updating"
rm -f "${STATES_DIR}/update-request"

rm -f "$HANDLERS_LOCK_FILE"
