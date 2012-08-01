#! /bin/sh

. ./common.inc

[ $# != 1 ] && exit 1

pname="$1"
case "$pname" in
  menubar) ;;
  prefpane) ;;
  *) exit 1;;
esac

touch "${CONTROL_DIR}/gui-change-${pname}"
