#! /bin/sh

. ./common.inc

[ -s "$BLACKLIST_DOMAINS_TMP_FILE" ] || exit 0

tr -s '[:blank:]' '\n' \
  < "$BLACKLIST_DOMAINS_TMP_FILE" > "${BLACKLIST_DOMAINS_TMP_FILE}~" &&
mv "${BLACKLIST_DOMAINS_TMP_FILE}~" "$BLACKLIST_DOMAINS_FILE"

exec ./switch-blacklists-on.sh
