#! /bin/sh

. ./common.inc

rm -f "$QUERY_LOG_FILE"
exec ./handle-control-change.sh --boot
