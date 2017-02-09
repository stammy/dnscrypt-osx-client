#! /bin/sh

. ./common.inc

args="$*"

[ $# -lt 1 ] && exit 1

servers=''
for server in $args; do
  servers="${servers} ${server}"
done
if [ "$servers" = "" ]; then
  rm -f "$STATIC_RESOLVERS_FILE"
else
  echo "$servers" | sed 's/^ *//;s/ *$//' > "$STATIC_RESOLVERS_FILE"
fi

exec ./switch-exceptions-on.sh
