#! /bin/sh

. ./common.inc

eval $(stat -s '/dev/console') || exit 1

logger_debug "OSX console ownership changed"

wanted_uid="$st_uid"
if [ ! -d "$DNSCRYPT_VAR_BASE_DIR" ]; then
  mkdir -p "$DNSCRYPT_VAR_BASE_DIR" || exit 1
  chown -R 0:0 "$DNSCRYPT_VAR_BASE_DIR"
  chmod 755 "$DNSCRYPT_VAR_BASE_DIR"
fi
mkdir -m 755 -p "$TICKETS_DIR" || exit 1
chown -R "${wanted_uid}:0" "$TICKETS_DIR"

mkdir -m 755 -p "$APP_UPDATES_DIR" || exit 1
chown -R "${wanted_uid}:0" "$APP_UPDATES_DIR"

eval $(stat -s "$CONTROL_DIR") || exit 1
if [ $? != 0 ]; then
  mkdir -m 755 -p "$CONTROL_DIR" || exit 1
  current_uid='nonexistent'
else
  current_uid="$st_uid"
fi

[ x"$current_uid" != x"$wanted_uid" ] && \
  chown -R "${wanted_uid}:0" "$CONTROL_DIR"
