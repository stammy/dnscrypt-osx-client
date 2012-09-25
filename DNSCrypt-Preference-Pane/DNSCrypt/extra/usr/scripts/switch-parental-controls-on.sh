#! /bin/sh

. ./common.inc

echo 'libdcplugin_example_ldns_opendns_parental_control.la' > \
  "$PARENTAL_CONTROLS_FILE"
touch "$PLUGINS_ENABLED_FILE"

