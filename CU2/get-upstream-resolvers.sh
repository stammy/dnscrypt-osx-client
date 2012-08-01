#! /bin/sh

. ./common.inc

opendns='no'
upstream_resolvers=''
while read resolver; do
  case "$resolver" in
    127.0.0.5*)
      opendns='yes'
    ;;
  esac
  if [ x"$upstream_resolvers" = 'x' ]; then
    upstream_resolvers="$resolver"
  else
    upstream_resolvers="${upstream_resolvers} $resolver"
  fi
done

if [ "$opendns" = 'yes' \
     -a -r "${STATES_DIR}/dnscrypt-proxy-description" ]; then
  cat "${STATES_DIR}/dnscrypt-proxy-description" && exit 0  
fi
echo "$upstream_resolvers"
exit 0

