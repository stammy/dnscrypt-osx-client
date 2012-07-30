#! /bin/ksh

. ./common.inc

ifs=$(ifconfig -a | \
  awk '/^[^ 	:]*:/ { sub(/:.*$/,empty); iface=$0 } /status: active/ { print iface }')
ifs=$(echo $ifs)

typeset -A found
ips=""
for i in $ifs; do
  ips_i=$(ipconfig getpacket "$i" 2> /dev/null | fgrep 'domain_name_server' | \
          sed -e 's/^.*{//' -e 's/,/ /g' -e 's/}//' )
  for ip_i in $ips_i; do
    if [ ! ${found["$ip_i"]} ]; then
      if [ "$ips" ]; then
        ips="$ips "
      fi
      ips="$ips$ip_i"
      found["$ip_i"]=1
    fi
  done
done

echo "$ips"
