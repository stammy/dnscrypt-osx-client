#! /bin/sh

. ./common.inc

[ $# != 1 ] && exit 1

pname="$1"
case "$pname" in
  menubar) ;;
  prefpane) ;;
  *) exit 1;;
esac

changed='no'
if [ -e "${TICKETS_DIR}/gui-change-${pname}" ]; then
  rm -f "${TICKETS_DIR}/gui-change-${pname}"
  changed='yes'
fi

echo "$changed"
