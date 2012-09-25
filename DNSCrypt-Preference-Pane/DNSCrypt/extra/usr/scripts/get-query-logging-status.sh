#! /bin/sh

. ./common.inc

if [ -e "$QUERY_LOGGING_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
