#! /bin/ksh
# /Library/Preferences/SystemConfiguration

. common.inc

NETWORK_STATE_FILE="${STATES_DIR}/network-state"
DHCP_DNS_FILE="${STATES_DIR}/dhcp-dns"
AIRPORT_TOOL="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"

mkdir -p "$STATES_DIR" || exit 1

ifs=$(ifconfig -a | \
  awk '/^[^ 	:]*:/ { sub(/:.*$/,empty); iface=$0 } /status: active/ { print iface }')
ifs=$(echo $ifs)

typeset -A found
ips=""
for i in $ifs; do
  ips_i=$(ipconfig getpacket $i | fgrep 'domain_name_server' | \
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

echo "$ips" > "$DHCP_DNS_FILE"

ssid=$("$AIRPORT_TOOL" -I 2>&1 | fgrep '[^B]SSID: ')
bssid=$("$AIRPORT_TOOL" -I 2>&1 | fgrep 'BSSID: ')
if [ -f "$NETWORK_STATE_FILE" ]; then
  if echo "$ifs $ips $ssid $bssid" | \
    cmp -- "$NETWORK_STATE_FILE" - >/dev/null; then
    exit 1
  fi
fi
echo "$ifs $ips $ssid $bssid" > "$NETWORK_STATE_FILE"
