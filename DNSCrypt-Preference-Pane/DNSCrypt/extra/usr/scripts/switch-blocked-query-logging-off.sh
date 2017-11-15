#! /bin/sh

. ./common.inc

rm -f "$BLOCKED_QUERY_LOGGING_FILE"

exec ./switch-blacklists-on.sh


