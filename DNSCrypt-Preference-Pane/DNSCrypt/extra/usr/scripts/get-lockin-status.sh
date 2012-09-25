#! /bin/sh

. ./common.inc

if [ -e "$LOCKIN_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
