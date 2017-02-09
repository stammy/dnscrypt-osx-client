#! /bin/sh

. ./common.inc

if [ ! -s "$EXCEPTIONS_TMP_FILE" ]; then
  rm -f "$EXCEPTIONS_FILE" "$EXCEPTIONS_TMP_FILE"
  exec ./switch-exceptions-off.sh
fi

tr -s '[:blank:]' '\n' < "$EXCEPTIONS_TMP_FILE" | \
  sed -e 's/^ *[*]*[.]*//' -e 's/ *$//' | \
  egrep -i '^\s*[0-9a-z_.-]+\s*$' > "${EXCEPTIONS_TMP_FILE}~" &&
mv "${EXCEPTIONS_TMP_FILE}~" "$EXCEPTIONS_FILE"

rm -f "$EXCEPTIONS_TMP_FILE"

exec ./switch-exceptions-on.sh
