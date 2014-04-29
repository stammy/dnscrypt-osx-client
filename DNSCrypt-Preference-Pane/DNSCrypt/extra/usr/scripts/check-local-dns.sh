#! /bin/sh

. ./common.inc

try_local_resolution() {
  exec dig +tries=2 +time=3 +short google-public-dns-a.google.com @$INTERFACE_PROXY \
    | egrep '^8[.]8[.]8[.]8' > /dev/null 2>&1
}

try_local_resolution
