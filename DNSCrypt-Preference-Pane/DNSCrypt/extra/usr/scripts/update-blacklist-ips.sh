#! /bin/sh

. ./common.inc

[ -s "$BLACKLIST_IPS_TMP_FILE" ] || exit 0

tr -s '[:blank:]' '\n' \
  < "$BLACKLIST_IPS_TMP_FILE" > "${BLACKLIST_IPS_TMP_FILE}~" &&
mv "${BLACKLIST_IPS_TMP_FILE}~" "$BLACKLIST_IPS_FILE"

exec ./switch-blacklists-on.sh
