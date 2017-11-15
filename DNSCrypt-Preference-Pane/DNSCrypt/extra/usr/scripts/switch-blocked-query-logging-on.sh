#! /bin/sh

. ./common.inc

touch "$BLOCKED_QUERY_LOGGING_FILE"

exec ./switch-blacklists-on.sh
