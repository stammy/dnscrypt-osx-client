#! /bin/sh

. common.inc

init_interfaces

mkdir -p -- "$DNSCRYPT_BASE_DIR" || exit 1

PROBES_BASE_DIR='/var/run/dnscrypt/probes'
rm -fr $PROBES_BASE_DIR || exit 1
mkdir -p -- "$PROBES_BASE_DIR" || exit 1

RES_DIR="${PROBES_BASE_DIR}/results" || exit 1
mkdir -p -- "$RES_DIR" || exit 1

PID_DIR="${PROBES_BASE_DIR}/pids" || exit 1
mkdir -p -- "$PID_DIR" || exit 1

DNSCRYPT_PROXY_BASE_DIR="${DNSCRYPT_BASE_DIR}/dnscrypt-proxy"
mkdir -p -- "$DNSCRYPT_PROXY_BASE_DIR" || exit 1

PROXY_PID_FILE="${DNSCRYPT_PROXY_BASE_DIR}/dnscrypt-proxy.pid"

try_resolver() {
  local priority="$1"
  local pid_file="${PID_DIR}/${priority}.pid"
  shift
  local args="$*"

  exec alarmer 3 dnscrypt-proxy --pid="$pid_file" 2>&1 \
    --local-address="${INTERFACE_PROBES}:${priority}" $args | \
  while read line; do
    case "$line" in
      *Proxying\ from\ *)
        answers=$(exec dig +time=1 +short +tries=2 -p $priority \
          @"$INTERFACE_PROBES" dailymotion.com 2> /dev/null | \
          fgrep -v 67.215.65. | wc -l)
        [ -r "$pid_file" ] && kill $(cat -- "$pid_file")
        if [ $answers -gt 0 ]; then
          echo "$args" > "${RES_DIR}/${priority}"
        fi
        ;;
      *) ;;
    esac
  done
}

[ -r "$PROXY_PID_FILE" ] && kill $(cat "$PROXY_PID_FILE") && sleep 1
ping6 -c 1 2620:0:ccc::2 > /dev/null 2>&1
ipv6_supported="no"
[ $? = 0 ] && ipv6_supported="yes"
wait_pids=""
if [ ipv6_supported = "yes" ]; then
  try_resolver 2000 "--resolver-address=[2620:0:ccc::2]:443" &
  wait_pids="$wait_pids $!"
  try_resolver 2001 "--resolver-address=[2620:0:ccc::2]:53" &
  wait_pids="$wait_pids $!"    
  try_resolver 2002 "--resolver-address=[2620:0:ccc::2]:443 --tcp-only" &
  wait_pids="$wait_pids $!"    
  try_resolver 2003 "--resolver-address=[2620:0:ccc::2]:53 --tcp-only" &
  wait_pids="$wait_pids $!"
fi
try_resolver 2004 "--resolver-address=208.67.220.220:443" &
wait_pids="$wait_pids $!"    
try_resolver 2005 "--resolver-address=208.67.220.220:53" &
wait_pids="$wait_pids $!"    
try_resolver 2006 "--resolver-address=208.67.220.220:443 --tcp-only" &
wait_pids="$wait_pids $!"    
try_resolver 2007 "--resolver-address=208.67.220.220:53 --tcp-only" &    
wait_pids="$wait_pids $!"    

for pid in $wait_pids; do
  wait $pid
  best_file=$(ls "$RES_DIR" | head -n 1)
  [ x"$best_file" != "x" ] && break
done

[ x"$best_file" = "x" ] && exit 1
best_args=$(cat "${RES_DIR}/${best_file}")

dnscrypt-proxy $best_args --local-address="${INTERFACE_PROXY}" \
  --pidfile="$PROXY_PID_FILE" --daemonize || exit 1

i=0
while [ $i -lt 30 ]; do
  ./check-local-dns.sh && break
  sleep 0.1
  i=$((i + 1))
done
