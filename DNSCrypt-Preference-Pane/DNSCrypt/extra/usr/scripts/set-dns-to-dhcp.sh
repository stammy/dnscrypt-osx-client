#! /bin/sh

. ./common.inc

servers='empty'

[ -e "$INSECURE_OPENDNS_FILE" ] && servers='208.67.220.220'
[ -e "$FAMILYSHIELD_FILE" ] && servers='208.67.220.123'

exec networksetup -listallnetworkservices 2>/dev/null | \
fgrep -v '*' | while read x ; do
  networksetup -setdnsservers "$x" "$servers"
done
dscacheutil -flushcache 2> /dev/null
killall -HUP mDNSResponder 2> /dev/null
exit 0
