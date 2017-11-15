#! /bin/sh

. ./common.inc

servers="$*"

[ $# -lt 1 ] && exit 1

logger_debug "Setting DNS resolvers to [$servers]"

exec networksetup -listallnetworkservices 2>/dev/null | \
fgrep -v '*' | while read x ; do
  networksetup -setdnsservers "$x" $servers
done

logger_debug "Flushing local DNS cache"

dscacheutil -flushcache 2> /dev/null
killall -HUP mDNSResponder 2> /dev/null
exit 0
