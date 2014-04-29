#! /bin/sh

. ./common.inc

PROCESSED_TICKETS_FILE="${STATES_DIR}/processed-tickets"

update() {
  lockfile -1 -r 30 -l 60 "$HANDLERS_LOCK_FILE" || exit 1

  if [ -e "$DNSCRYPT_FILE" ]; then
    ./switch-to-dnscrypt-if-required.sh
  else
    ./stop-dnscrypt-proxy.sh
    ./switch-to-dhcp-if-required.sh
  fi

  rm -f "$HANDLERS_LOCK_FILE"
}

touch "${STATES_DIR}/updating"

logger_debug "DNSCrypt-OSXClient configuration changed"

updated='no'
while :; do
  find "$TICKETS_DIR" -type f -name 'ticket-*' > "$PROCESSED_TICKETS_FILE"
  if [ ! -s "$PROCESSED_TICKETS_FILE" -a "$updated" = 'yes' ]; then
    break
  fi
  update
  updated='yes'
  while read ticket_file; do
    rm -f "$ticket_file"
  done < "$PROCESSED_TICKETS_FILE"
done

rm -f "${STATES_DIR}/updating"
rm -f "${STATES_DIR}/update-request"
