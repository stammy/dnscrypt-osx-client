#! /bin/sh

. ./common.inc

plugin_args=''

[ -s "$BLACKLIST_IPS_FILE" ] && \
  plugin_args="${plugin_args},--ips='${BLACKLIST_IPS_FILE}'"

[ -s "$BLACKLIST_DOMAINS_FILE" ] && \
  plugin_args="${plugin_args},--domains='${BLACKLIST_DOMAINS_FILE}'"

[ -e "$BLOCKED_QUERY_LOGGING_FILE" ] && \
  plugin_args="${plugin_args},--logfile='${BLOCKED_QUERY_LOG_FILE}'"

[ -z "$plugin_args" ] && exec ./switch-blacklists-off.sh

echo "libdcplugin_example_ldns_blocking.la${plugin_args}" > \
  "$BLOCKING_FILE"
touch "$PLUGINS_ENABLED_FILE"
