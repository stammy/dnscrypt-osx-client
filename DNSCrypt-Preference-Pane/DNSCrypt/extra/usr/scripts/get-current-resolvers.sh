#! /bin/ksh

. ./common.inc

[ -r /etc/resolv.conf ] || exit 0
ips_i=""
while read line; do
  case "$line" in
    nameserver\ *)
      ip=$(echo "$line" | sed -e 's/nameserver *//' -e 's/ *//')
      ips_i="$ips_i $ip"
    ;;
  esac
done < /etc/resolv.conf

typeset -A found
ips=""
for ip_i in $ips_i; do
  if [ ! ${found["$ip_i"]} ]; then
    if [ "$ips" ]; then
      ips="$ips "
    fi
    ips="$ips$ip_i"
    found["$ip_i"]=1
  fi
done

echo "$ips"
