#! /bin/sh

. ./common.inc

rm -f "$QUERY_LOG_FILE"
rm -f "$DEBUG_LOG_FILE"
rm -f "$RESOLVERS_LIST_STATE"

./clear-fw.sh

exec ./handle-control-change.sh --boot
