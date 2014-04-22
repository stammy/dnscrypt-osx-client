#! /bin/sh

. ./common.inc

DNSCRYPT_LIB_BASE_DIR="${DNSCRYPT_USR_BASE_DIR}/lib"
export DYLD_LIBRARY_PATH="${DNSCRYPT_LIB_BASE_DIR}:${DYLD_LIBRARY_PATH}"

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

RESOLVER_NAME=$(./get-dnscrypt-resolver-name.sh) || exit 1

try_resolver() {
  local priority="$1"
  shift
  local description="$1"
  shift
  local args="$*"
  local pid_file="${PID_DIR}/${priority}.pid"

  rm -f "${RES_DIR}/${priority}"
  exec alarmer 3 dnscrypt-proxy --pid="$pid_file" \
    --resolver-name="$RESOLVER_NAME" \
    --local-address="${INTERFACE_PROBES}:${priority}" $args 2>&1 | \
  while read line; do
    case "$line" in
      *Proxying\ from\ *)
        answers=$(exec dig +time=1 +short +tries=2 -p $priority \
          @"$INTERFACE_PROBES" www.apple.com. 2> /dev/null | \
          egrep -ic '^[0-9.:]+$')
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

get_plugin_args() {
  cat "$DNSCRYPT_PROXY_PLUGINS_BASE_FILE"[s-]*.enabled | { \
    local plugin_args=''
    local quoted_line

    while read line; do
      case "$line" in
        libdcplugin_*) plugin_args="${plugin_args} --plugin=${line}" ;;
      esac
    done
    echo "$plugin_args"
  }
}

./stop-dnscrypt-proxy.sh

ipv6_supported="no"
if [ x"$DISABLE_IPV6" = "xno" ]; then
  ping6 -c 1 2620:0:ccc::2 > /dev/null 2>&1
  [ $? = 0 ] && ipv6_supported="yes"
fi

wait_pids=""

try_resolver 5004 "${RESOLVER_NAME} using DNSCrypt over UDP" \
  "--resolver-name=$RESOLVER_NAME" &
wait_pids="$wait_pids $!"

try_resolver 5005 "${RESOLVER_NAME} using DNSCrypt over TCP" \
  "--resolver-name=$RESOLVER_NAME --tcp-only" &
wait_pids="$wait_pids $!"

for pid in $wait_pids; do
  wait $pid
  best_file=$(ls "$RES_DIR" | head -n 1)
  [ x"$best_file" != "x" ] && break
done

[ x"$best_file" = "x" ] && exit 1

plugins_args=''
if [ -r "${DNSCRYPT_PROXY_PLUGINS_BASE_FILE}s.enabled" ]; then
  plugin_args=$(get_plugin_args)
fi
[ "$ipv6_supported" = "no" ] && \
  plugin_args="${plugin_args} --plugin=libdcplugin_example_ldns_aaaa_blocking.la"

best_args=$(cat "${RES_DIR}/${best_file}")

eval dnscrypt-proxy $best_args --local-address="$INTERFACE_PROXY" \
  --resolver-name="$RESOLVER_NAME" \
  --pidfile="$PROXY_PID_FILE" --user=daemon --daemonize $plugin_args

if [ $? != 0 ]; then
  [ -r "$PROXY_PID_FILE" ] && kill $(cat -- "$PROXY_PID_FILE")
  sleep 1
  killall dnscrypt-proxy
  sleep 1
  rm -f "$PROXY_PID_FILE"
  killall -9 dnscrypt-proxy
  sleep 1
  eval dnscrypt-proxy $best_args --local-address="$INTERFACE_PROXY" \
    --resolver-name="$RESOLVER_NAME" \
    --pidfile="$PROXY_PID_FILE" --user=daemon --daemonize $plugin_args || \
    exit 1
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
