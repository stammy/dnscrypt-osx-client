#! /bin/sh

. ./common.inc

logger_debug "Stopping dnscrypt-proxy"

if [ -x /usr/bin/pgrep ]; then
  pgrep -x dnscrypt-proxy | egrep '[0-9]+' > /dev/null || exit 0
fi

[ ! -r "$PROXY_PID_FILE" ] && exit 0
pid=$(cat "$PROXY_PID_FILE")
[ $pid -lt 2 ] && exit 0

logger_debug "Trying to stop dnscrypt-proxy by killing pid [$pid]"
kill $pid

i=0
while [ $i -lt 30 ]; do
  [ ! -r "$PROXY_PID_FILE" ] && exit 0
  sleep 0.1
  i=$((i + 1))
done

rm -f "$PROXY_PID_FILE"
kill -9 $pid

logger_debug "Killed dnscrypt-proxy with kill -9 pid [$pid]"
