#! /bin/sh

. ./common.inc

get_opendns_config() {
  exec dig +tries=3 +time=3 +short txt debug.opendns.com @208.67.222.222
}

get_client_ip() {
  local client_ip=''
  local has_thing_id='false'

  while read line; do
    case "$line" in
      \"id\ *) has_thing_id='true' ;;
      \"source\ *) client_ip=$(echo "$line" | cut -d' ' -f2 | cut -d ':' -f1) ;;
    esac
  done
  [ x"$client_ip" != 'x' ] && echo "$client_ip" | egrep '^[0-9.]{1,15}$'
}

hex_ip() {
  local dec="$1"
  local hex=''
  local OIFS="$IFS"
  local p
  
  IFS='.'
  for p in $dec; do
    hex="${hex}$(printf '%02x' $p)"
  done
  IFS="$OIFS"  
  echo "$hex"
}

client_ip=$(get_opendns_config | get_client_ip) || exit 1
client_ip_hex=$(hex_ip "$client_ip")

echo "libdcplugin_example_ldns_opendns_set_client_ip.la,${client_ip_hex}" > \
  "$LOCKIN_FILE"

touch "$PLUGINS_ENABLED_FILE"
