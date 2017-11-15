#! /bin/sh

. ./common.inc

exec >/dev/null
exec 2>&1

SOCKETFILTERFW='/usr/libexec/ApplicationFirewall/socketfilterfw'
[ -x "$SOCKETFILTERFW" ] || exit 0

"$SOCKETFILTERFW" --add        "${DNSCRYPT_USR_BASE_DIR}/sbin/dnscrypt-proxy"
"$SOCKETFILTERFW" --unblockapp "${DNSCRYPT_USR_BASE_DIR}/sbin/dnscrypt-proxy"

"$SOCKETFILTERFW" --add        "${DNSCRYPT_USR_BASE_DIR}/bin/hostip"
"$SOCKETFILTERFW" --unblockapp "${DNSCRYPT_USR_BASE_DIR}/bin/hostip"
