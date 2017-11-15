#! /bin/sh

. ./common.inc

[ -r "$STATIC_RESOLVERS_FILE" ] && cat "$STATIC_RESOLVERS_FILE" && exit 0
exit 1

