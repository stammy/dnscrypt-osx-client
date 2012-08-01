#! /bin/sh

. ./common.inc

try_local_resolution() {
  exec dig +tries=2 +time=3 +short resolver1.opendns.com @$INTERFACE_PROXY \
    | egrep '^208[.]67[.]' > /dev/null 2>&1
}

try_local_resolution
