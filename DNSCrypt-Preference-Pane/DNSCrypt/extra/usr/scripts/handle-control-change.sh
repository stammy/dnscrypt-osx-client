#! /bin/sh

. ./common.inc

PROCESSED_TICKETS_FILE="${STATES_DIR}/processed-tickets"

logger_debug handle_control_change

update() {
  lockfile -1 -r 30 "$HANDLERS_LOCK_FILE" || exit 1

  if [ -e "$DNSCRYPT_FILE" ]; then
    ./switch-to-dnscrypt-if-required.sh
  else
    ./stop-dnscrypt-proxy.sh
    ./switch-to-dhcp-if-required.sh
  fi

  rm -f "$HANDLERS_LOCK_FILE"
}

touch "${STATES_DIR}/updating"

updated='no'
while :; do
  find "$TICKETS_DIR" -type f -name 'ticket-*' > "$PROCESSED_TICKETS_FILE"
  if [ ! -s "$PROCESSED_TICKETS_FILE" -a "$updated" = 'yes' ]; then
    break
  fi
  logger_debug "New tickets found"
  find "$CONTROL_DIR" -type f -name '[a-zA-Z0-9]*' \! -name '*.tmp' \
    -exec md5 {} \; > "${STATES_DIR}/controls.cksum.new"
  if cmp -s "${STATES_DIR}/controls.cksum.new" "${STATES_DIR}/controls.cksum"; then
    logger_debug "Content of the controls dir actually didn't change"
  else
    update
    mv -f "${STATES_DIR}/controls.cksum.new" "${STATES_DIR}/controls.cksum"
  fi
  updated='yes'
  while read ticket_file; do
    rm -f "$ticket_file"
  done < "$PROCESSED_TICKETS_FILE"
done

rm -f "${STATES_DIR}/updating"
rm -f "${STATES_DIR}/update-request"
