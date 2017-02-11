#! /bin/ksh

. ./common.inc

PAUSE_MAX=50
PAUSE_UNIT=0.1
PAUSE_INCREMENT=1

[ ! -e "$DNSCRYPT_FILE" ] && exit 0

logger_debug "DNSCrypt has been requested"

pause=0
while [ -e "$DNSCRYPT_FILE" ]; do
  logger_debug "Switching to dnscrypt if required (pause=$pause)"
  current_resolvers=$(./get-current-resolvers.sh)
  if [ "$current_resolvers" = "$INTERFACE_PROXY" ]; then
    if [ ! -e "$PROXY_PID_FILE" ]; then
      rm -f "${STATES_DIR}/controls.cksum"
      logger_debug "The proxy should be running but it isn't."
      ./switch-to-dhcp.sh
    fi
  fi
  pause_counter=0
  while [ -e "$DNSCRYPT_FILE" -a $pause_counter -lt $pause ]; do
    sleep $PAUSE_UNIT
    pause_counter=$((pause_counter + 1))
  done
  [ $pause -lt $PAUSE_MAX ] && pause=$((pause + 1))
  [ ! -e "$DNSCRYPT_FILE" ] && break
  ./start-dnscrypt-proxy.sh || continue
  ./set-dns.sh "$INTERFACE_PROXY"
  if [ $? != 0 ]; then
    logger_debug "Setting the DNS to [$INTERFACE_PROXY] didn't work"
    ./set-dns-to-dhcp.sh
    continue
  fi
  break
done

if [ ! -e "$DNSCRYPT_FILE" ]; then
  touch "$CONTROL_DIR"
  exit 0
fi

exec ./exceptions-add.sh
