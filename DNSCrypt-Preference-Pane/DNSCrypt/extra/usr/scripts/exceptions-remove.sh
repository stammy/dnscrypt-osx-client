#! /bin/sh

RESOLVER_DIR='/etc/resolver'

. ./common.inc

for domain in $DOMAINS_EXCEPTIONS; do
  rm -f "${RESOLVER_DIR}/${domain}"
done
