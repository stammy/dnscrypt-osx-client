#! /bin/sh

. ./common.inc

[ $# -lt 1 ] && exit 1

resolver_name="$1"

if [ "$resolver_name" = "" ]; then
  rm -f "$DNSCRYPT_RESOLVER_NAME_FILE"
else
  echo "$resolver_name" | sed 's/^ *//;s/ *$//' \
  > "$DNSCRYPT_RESOLVER_NAME_FILE"
fi
