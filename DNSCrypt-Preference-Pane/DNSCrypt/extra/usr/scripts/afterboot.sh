#! /bin/sh

. ./common.inc

rm -f "$QUERY_LOG_FILE"
rm -f "$DEBUG_LOG_FILE"
find -x "$RESOLVERS_LIST_STATE" -type f -mtime +1 -exec rm -f {} \; 2>/dev/null

./clear-fw.sh

exec ./handle-control-change.sh --boot
