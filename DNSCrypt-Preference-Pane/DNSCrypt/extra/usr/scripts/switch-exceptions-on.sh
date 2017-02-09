#! /bin/sh

. ./common.inc

get_gw() {
  route -n get default | while read line; do
    case "$line" in
      gateway:\ *)
        echo "$line" | sed 's/ *gateway: *//'
        return
      ;;
    esac
  done
}

get_dhcp_dns() {
  cat "$DHCP_DNS_FILE" 2> /dev/null | egrep -i '^[0-9a-f:.]+$'
}

[ -s "$EXCEPTIONS_FILE" ] || exec ./switch-exceptions-off.sh

domains=''
while read domain; do
  domains="${domain} ${domains}"
done < "$EXCEPTIONS_FILE"

[ -z "$domains" ] && exec ./switch-exceptions-off.sh

resolvers=$(./get-static-resolvers.sh || get_dhcp_dns || get_gw)

[ -z "$resolvers" ] && exec ./switch-exceptions-off.sh

plugin_args=''
plugin_args="${plugin_args},--domains='${domains}'"
plugin_args="${plugin_args},--resolvers='${resolvers}'"

echo "libdcplugin_example_ldns_forwarding.la${plugin_args}" > \
  "$FORWARDING_FILE"
touch "$PLUGINS_ENABLED_FILE"
