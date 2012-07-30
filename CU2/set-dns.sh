#! /bin/sh

. ./common.inc

servers="$*"

[ $# -lt 1 ] && exit 1
exec networksetup -listallnetworkservices 2>/dev/null | \
fgrep -v '*' | while read x ; do
  networksetup -setdnsservers "$x" $servers
done
