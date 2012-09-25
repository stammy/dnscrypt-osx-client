#! /bin/sh

. ./common.inc

if [ -e "$PARENTAL_CONTROLS_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
