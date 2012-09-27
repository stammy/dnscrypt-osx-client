#! /bin/sh

. ./common.inc

if [ ! -s "$EXCEPTIONS_TMP_FILE" ]; then
  rm -f "$EXCEPTIONS_FILE" "$EXCEPTIONS_TMP_FILE"
  exit 0
fi

tr -s '[:blank:]' '\n' < "$EXCEPTIONS_TMP_FILE" | \
  egrep -i '^\s*[0-9a-z_.-]+\s*$' > "${EXCEPTIONS_TMP_FILE}~" &&
mv "${EXCEPTIONS_TMP_FILE}~" "$EXCEPTIONS_FILE"
