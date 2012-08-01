#! /bin/sh

. ./common.inc

if [ -e "$FAMILYSHIELD_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
