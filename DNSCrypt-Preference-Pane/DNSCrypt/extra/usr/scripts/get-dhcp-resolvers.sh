#! /bin/ksh

. ./common.inc

get_ifs() {
  ifs_save="$IFS"
  IFS=''
  ifconfig -a | while read line; do
    nif=$(echo "$line" | egrep -i '^[^ 	]+:\s+flags' | sed 's/:.*$//')
    isact=$(echo "$line" | egrep -i 'status:\s*active')
    if [ -n "$nif" ]; then
      cif="$nif"
    elif [ -n "$isact" -a -n "$cif" ]; then
      echo $cif
    fi
  done
  IFS="$ifs_save"
}

ifs=$(get_ifs)

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
