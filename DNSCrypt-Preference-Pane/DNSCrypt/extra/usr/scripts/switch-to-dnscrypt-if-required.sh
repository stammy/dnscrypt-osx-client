#! /bin/ksh

. ./common.inc

PAUSE_MAX=10
PAUSE_INCREMENT=0.1

[ ! -e "$DNSCRYPT_FILE" ] && exit 0

current_resolvers=$(./get-current-resolvers.sh)
if [ "$current_resolvers" = '127.0.0.54' ]; then
  if [ ! -e "$PROXY_PID_FILE" ]; then
    ./start-dnscrypt-proxy.sh || ./switch-to-dhcp.sh
  fi
fi

pause=0
while [ -e "$DNSCRYPT_FILE" ]; do
  if [ $pause -lt $PAUSE_MAX ]; then
    pause=$((pause + $PAUSE_INCREMENT))
  fi
  sleep $pause
  ./check-hijacking.sh || continue
  ./start-dnscrypt-proxy.sh || continue
  ./check-local-dns.sh || continue
  ./set-dns.sh "$INTERFACE_PROXY"
  if [ $? != 0 ]; then
    ./set-dns-to-dhcp.sh
    continue
  fi
  ./check-hijacking.sh
  if [ $? != 0 ]; then
    ./set-dns-to-dhcp.sh
    continue
  fi
  break
done

if [ ! -e "$DNSCRYPT_FILE" ]; then
  touch "$CONTROL_DIR"
fi

exec ./exceptions-add.sh
