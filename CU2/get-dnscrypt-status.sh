#! /bin/sh

. ./common.inc

if [ -e "$DNSCRYPT_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
