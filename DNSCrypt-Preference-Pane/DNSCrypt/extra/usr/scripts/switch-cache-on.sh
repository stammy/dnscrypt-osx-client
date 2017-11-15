#! /bin/sh

. ./common.inc

echo "libdcplugin_example_cache.la" > \
  "$CACHE_FILE"

touch "$PLUGINS_ENABLED_FILE"
