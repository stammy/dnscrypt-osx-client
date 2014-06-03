#! /bin/ksh

. ./common.inc

PAUSE_MAX=10
PAUSE_INCREMENT=0.1

[ ! -e "$DNSCRYPT_FILE" ] && exit 0

logger_debug "DNSCrypt has been requested"

./set-dns-to-dhcp.sh

pause=0
while [ -e "$DNSCRYPT_FILE" ]; do
  logger_debug "Switching to dnscrypt if required (pause=$pause)"
  current_resolvers=$(./get-current-resolvers.sh)
  if [ "$current_resolvers" = "$INTERFACE_PROXY" ]; then
    if [ ! -e "$PROXY_PID_FILE" ]; then
      logger_debug "The proxy should be running but it isn't. Launching it."
      ./start-dnscrypt-proxy.sh || ./switch-to-dhcp.sh
    fi
  fi
  if [ $pause -lt $PAUSE_MAX ]; then
    pause=$((pause + $PAUSE_INCREMENT))
  fi
  sleep $pause
  logger_debug "Checking if the router hijacks HTTP queries"
  if ./check-hijacking.sh; then
    logger_debug "The router doesn't hijack HTTP queries"
  else
    logger_debug "The router hijacks HTTP queries - DNSCrypt is likely to be blocked"
    continue
  fi
  ./check-local-dns.sh || continue
  ./set-dns.sh "$INTERFACE_PROXY"
  if [ $? != 0 ]; then
    logger_debug "Setting the DNS to [$INTERFACE_PROXY] didn't work"
    ./set-dns-to-dhcp.sh
    continue
  fi
  ./check-hijacking.sh
  if [ $? != 0 ]; then
    logger_debug "Current configuration seems to be hijacking HTTP queries. Reverting to default resolvers."
    ./set-dns-to-dhcp.sh
    continue
  fi
  break
done

if [ ! -e "$DNSCRYPT_FILE" ]; then
  touch "$CONTROL_DIR"
fi

exec ./exceptions-add.sh
