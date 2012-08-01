#! /bin/sh

. ./common.inc

if [ -e "$INSECURE_OPENDNS_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
