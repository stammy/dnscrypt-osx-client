#! /bin/sh

. ./common.inc

NETWORK_STATE_FILE="${STATES_DIR}/network-state"
DHCP_DNS_FILE="${STATES_DIR}/dhcp-dns"
AIRPORT_TOOL="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"

mkdir -p "$STATES_DIR" || exit 1
ips=$(./get-current-resolvers.sh)
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
