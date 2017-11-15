#! /bin/sh

. ./common.inc

if [ -e "$BLOCKED_QUERY_LOGGING_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
