#! /bin/sh

. ./common.inc

if [ ! -s "$BLACKLIST_IPS_TMP_FILE" ]; then
  rm -f "$BLACKLIST_IPS_FILE"
  exec ./switch-blacklists-on.sh
fi

tr -s '[:blank:]' '\n' \
  < "$BLACKLIST_IPS_TMP_FILE" > "${BLACKLIST_IPS_TMP_FILE}~" &&
mv "${BLACKLIST_IPS_TMP_FILE}~" "$BLACKLIST_IPS_FILE"

exec ./switch-blacklists-on.sh
