#! /bin/sh

. ./common.inc

if [ -e "$FALLBACK_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
