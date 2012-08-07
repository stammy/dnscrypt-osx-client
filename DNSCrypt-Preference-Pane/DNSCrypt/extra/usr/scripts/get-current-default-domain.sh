#! /bin/ksh

. ./common.inc

[ -r /etc/resolv.conf ] || exit 0
domain=""
while read line; do
  case "$line" in
    domain\ *)
      domain=$(echo "$line" | sed -e 's/domain *//' -e 's/ *//')
      break
    ;;
  esac
done < /etc/resolv.conf

echo "$domain"
