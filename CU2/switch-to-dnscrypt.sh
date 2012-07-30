#! /bin/ksh

. common.inc

PAUSE_MAX=10
PAUSE_INCREMENT=0.1
DNSCRYPT_FILE="${CONTROL_DIR}/dnscrypt"

[ ! -e "$DNSCRYPT_FILE" ] && exit 0

pause=0
while :; do
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
