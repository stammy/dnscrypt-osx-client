#! /bin/sh

. ./common.inc

servers='empty'

logger_debug "Changing the DNS configuration to use the default DNS resolvers"

if [ -r "$STATIC_RESOLVERS_FILE" ]; then
  servers=''
  while read server; do
    case "$server" in
      [0-9a-fA-F:.]*) servers="${servers} ${server}" ;;
    esac
  done < "$STATIC_RESOLVERS_FILE"
  [ -z "$servers" ] && servers='empty'
  logger_debug "Static list of DNS resolvers: [$servers]"
fi

exec networksetup -listallnetworkservices 2>/dev/null | \
fgrep -v '*' | while read x ; do
  networksetup -setdnsservers "$x" $servers > /dev/null
done

logger_debug "Flushing the local DNS cache"

dscacheutil -flushcache 2> /dev/null
killall -HUP mDNSResponder 2> /dev/null
exit 0
