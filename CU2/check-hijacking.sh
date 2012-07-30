#! /bin/sh

. ./common.inc

try_resolution() {
  exec alarmer 5 dig +tries=2 +time=3 +short resolver1.opendns.com \
    | egrep '^208[.]67[.]' > /dev/null 2>&1
}

try_http_query() {
  exec alarmer 5 curl -m 5 http://www.opendns.com 2>/dev/null | \
  fgrep -ic OpenDNS > /dev/null 2>&1
}

try_everything() {
  try_resolution &
  resolution_pid=$!
  try_http_query &
  http_query_pid=$!
  wait $resolution_pid
  resolution_ret=$?
  if [ $resolution_ret != 0 ]; then
    return 1
  fi
  wait $http_query_pid
  http_query_ret=$?
  [ $resolution_ret = 0 -a $http_query_ret = 0 ]
}

try_everything_with_retries() {
  try_everything || try_everything
}

try_everything_with_retries
