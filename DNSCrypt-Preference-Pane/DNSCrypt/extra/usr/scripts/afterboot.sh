#! /bin/sh

. ./common.inc

rm -f "$BLOCKED_QUERY_LOG_FILE"
rm -f "$QUERY_LOG_FILE"
rm -f "$DEBUG_LOG_FILE"
find -x "$RESOLVERS_LIST_STATE" -type f -mtime +1 -exec rm -f {} \; 2>/dev/null
find -x "$APP_UPDATES_STATE" -type f -mtime +1 -exec rm -f {} \; 2>/dev/null
find -x "$STATES_DIR" -type f -exec rm -f {} -exec rm -f {} \; 2>/dev/null

./clear-fw.sh

exec ./handle-control-change.sh --boot
