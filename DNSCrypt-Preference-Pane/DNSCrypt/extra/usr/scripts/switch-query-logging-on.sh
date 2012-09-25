#! /bin/sh

. ./common.inc

echo "libdcplugin_example_logging.la,${QUERY_LOG_FILE}" > \
  "$QUERY_LOGGING_FILE"

touch "$PLUGINS_ENABLED_FILE"
