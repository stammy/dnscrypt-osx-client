#! /bin/sh

. ./common.inc

init_interfaces

mkdir -p -- "$DNSCRYPT_VAR_BASE_DIR" || exit 1

PROBES_BASE_DIR="${DNSCRYPT_VAR_BASE_DIR}/probes"
rm -fr "$PROBES_BASE_DIR" || exit 1
mkdir -p -- "$PROBES_BASE_DIR" || exit 1

RES_DIR="${PROBES_BASE_DIR}/results" || exit 1
mkdir -p -- "$RES_DIR" || exit 1

DESCRIPTIONS_DIR="${PROBES_BASE_DIR}/results-descriptions" || exit 1
mkdir -p -- "$DESCRIPTIONS_DIR" || exit 1

PID_DIR="${PROBES_BASE_DIR}/pids" || exit 1
mkdir -p -- "$PID_DIR" || exit 1

try_resolver() {
  local priority="$1"
  shift
  local description="$1"
  shift
  local args="$*"
  local pid_file="${PID_DIR}/${priority}.pid"

  rm -f "${RES_DIR}/${priority}"
  exec alarmer 3 dnscrypt-proxy --user=daemon --pid="$pid_file" \
    --local-address="${INTERFACE_PROBES}:${priority}" $args 2>&1 | \
  while read line; do
    case "$line" in
      *Proxying\ from\ *)
        answers=$(exec dig +time=1 +short +tries=2 -p $priority \
          TXT @"$INTERFACE_PROBES" debug.opendns.com. 2> /dev/null | \
          fgrep -ic 'dnscrypt enabled')
        [ -r "$pid_file" ] && kill $(cat -- "$pid_file")
        if [ $answers -gt 0 ]; then
          echo "$args" > "${RES_DIR}/${priority}"
          echo "$description" > "${DESCRIPTIONS_DIR}/${priority}"
        fi
        ;;
      *) ;;
    esac
  done
}

./stop-dnscrypt-proxy.sh

ping6 -c 1 2620:0:ccc::2 > /dev/null 2>&1
ipv6_supported="no"
[ $? = 0 ] && ipv6_supported="yes"

familyshield_wanted="no"
[ -r "$FAMILYSHIELD_FILE" ] && familyshield_wanted="yes"

wait_pids=""
if [ x"$familyshield_wanted" = "xyes" ]; then
  try_resolver 4000 'FamilyShield using DNSCrypt on UDP port 443' \
    "--resolver-address=208.67.220.123:443" &
  wait_pids="$wait_pids $!"
  try_resolver 4001 'FamilyShield using DNSCrypt on UDP port 53' \
    "--resolver-address=208.67.220.123:53" &
  wait_pids="$wait_pids $!"
  try_resolver 4002 'FamilyShield using DNSCrypt on TCP port 443' \
    "--resolver-address=208.67.220.123:443 --tcp-only" &
  wait_pids="$wait_pids $!"
  try_resolver 4003 'FamilyShield using DNSCrypt on TCP port 53' \
    "--resolver-address=208.67.220.123:53 --tcp-only" &
  wait_pids="$wait_pids $!"
fi
if [ x"$ipv6_supported" = "xyes" ]; then
  try_resolver 5000 'OpenDNS IPv6 using DNSCrypt on UDP port 443' \
    "--resolver-address=[2620:0:ccc::2]:443" &
  wait_pids="$wait_pids $!"
  try_resolver 5001 'OpenDNS IPv6 using DNSCrypt on UDP port 53' \
    "--resolver-address=[2620:0:ccc::2]:53" &
  wait_pids="$wait_pids $!"
  try_resolver 5002 'OpenDNS IPv6 using DNSCrypt on TCP port 443' \
    "--resolver-address=[2620:0:ccc::2]:443 --tcp-only" &
  wait_pids="$wait_pids $!"    
  try_resolver 5003 'OpenDNS IPv6 using DNSCrypt on TCP port 53' \
    "--resolver-address=[2620:0:ccc::2]:53 --tcp-only" &
  wait_pids="$wait_pids $!"
fi
try_resolver 5004 'OpenDNS using DNSCrypt on UDP port 443' \
  "--resolver-address=208.67.220.220:443" &
wait_pids="$wait_pids $!"
try_resolver 5005 'OpenDNS using DNSCrypt on UDP port 53' \
  "--resolver-address=208.67.220.220:53" &
wait_pids="$wait_pids $!"    
try_resolver 5006 'OpenDNS using DNSCrypt on TCP port 443' \
  "--resolver-address=208.67.220.220:443 --tcp-only" &
wait_pids="$wait_pids $!"    
try_resolver 5007 'OpenDNS using DNSCrypt on TCP port 53' \
  "--resolver-address=208.67.220.220:53 --tcp-only" &
wait_pids="$wait_pids $!"    

for pid in $wait_pids; do
  wait $pid
  best_file=$(ls "$RES_DIR" | head -n 1)
  [ x"$best_file" != "x" ] && break
done

[ x"$best_file" = "x" ] && exit 1
best_args=$(cat "${RES_DIR}/${best_file}")
dnscrypt-proxy $best_args --local-address="${INTERFACE_PROXY}" \
  --pidfile="$PROXY_PID_FILE" --user=daemon --daemonize
if [ $? != 0 ]; then
  [ -r "$PROXY_PID_FILE" ] && kill $(cat -- "$PROXY_PID_FILE")
  sleep 1
  killall dnscrypt-proxy
  sleep 1
  rm -f "$PROXY_PID_FILE"
  killall -9 dnscrypt-proxy
  sleep 1
  dnscrypt-proxy $best_args --local-address="${INTERFACE_PROXY}" \
    --pidfile="$PROXY_PID_FILE" --user=daemon --daemonize || exit 1
fi

i=0
while [ $i -lt 30 ]; do
  ./check-local-dns.sh && break
  sleep 0.1
  i=$((i + 1))
done

if [ $i -ge 30 ]; then
  ./switch-to-dhcp.sh
  exit 1
fi
mv "${DESCRIPTIONS_DIR}/${best_file}" \
   "${STATES_DIR}/dnscrypt-proxy-description" 2>/dev/null || exit 0
