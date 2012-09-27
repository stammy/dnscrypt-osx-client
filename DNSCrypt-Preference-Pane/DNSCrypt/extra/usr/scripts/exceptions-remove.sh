#! /bin/sh

RESOLVER_DIR='/etc/resolver'

. ./common.inc

[ -r "$EXCEPTIONS_FILE" ] &&
  DOMAINS_EXCEPTIONS="$(cat "$EXCEPTIONS_FILE") $DOMAINS_EXCEPTIONS"

for domain in $DOMAINS_EXCEPTIONS; do
  rm -f "${RESOLVER_DIR}/${domain}"
done
exit 0
