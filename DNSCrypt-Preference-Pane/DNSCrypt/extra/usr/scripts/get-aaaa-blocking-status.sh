#! /bin/sh

. ./common.inc

if [ -e "$AAAA_BLOCKING_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
