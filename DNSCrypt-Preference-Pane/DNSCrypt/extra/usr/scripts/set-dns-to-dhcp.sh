#! /bin/sh

. ./common.inc

servers='empty'

if [ -r "$STATIC_RESOLVERS_FILE" ]; then
  servers=''
  while read server; do
    case "$server" in
      [0-9a-fA-F:.]*) servers="${servers} ${server}" ;;
    esac
  done < "$STATIC_RESOLVERS_FILE"
  [ -z "$servers" ] && servers='empty'
fi

[ -e "$INSECURE_OPENDNS_FILE" ] && servers='208.67.220.220'
[ -e "$FAMILYSHIELD_FILE" ] && servers='208.67.220.123'

exec networksetup -listallnetworkservices 2>/dev/null | \
fgrep -v '*' | while read x ; do
  networksetup -setdnsservers "$x" $servers
done
dscacheutil -flushcache 2> /dev/null
killall -HUP mDNSResponder 2> /dev/null
exit 0
