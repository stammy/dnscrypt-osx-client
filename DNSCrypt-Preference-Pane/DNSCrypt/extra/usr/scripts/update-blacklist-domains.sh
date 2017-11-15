#! /bin/sh

. ./common.inc

if [ ! -s "$BLACKLIST_DOMAINS_TMP_FILE" ]; then
  rm -f "$BLACKLIST_DOMAINS_FILE" "$BLACKLIST_DOMAINS_TMP_FILE"
  exec ./switch-blacklists-on.sh
fi

tr -s '[:blank:]' '\n' < "$BLACKLIST_DOMAINS_TMP_FILE" | \
  egrep -i '^[*]?[.]?[^.][a-z0-9_.-]+[*]?$' > \
  "${BLACKLIST_DOMAINS_TMP_FILE}~" &&
mv "${BLACKLIST_DOMAINS_TMP_FILE}~" "$BLACKLIST_DOMAINS_FILE"

exec ./switch-blacklists-on.sh
