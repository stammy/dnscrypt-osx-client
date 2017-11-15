#! /bin/sh

. ./common.inc

if [ -e "$HIDE_MENUBAR_ICON_FILE" ]; then
  echo 'yes'
else
  echo 'no'
fi
