#! /bin/sh

. ./common.inc

exec >/dev/null
exec 2>&1

SOCKETFILTERFW='/usr/libexec/ApplicationFirewall/socketfilterfw'
[ ! -x "$SOCKETFILTERFW" ] && exit 0

"$SOCKETFILTERFW" --add        /usr/local/sbin/dnscrypt-proxy
"$SOCKETFILTERFW" --unblockapp /usr/local/sbin/dnscrypt-proxy

"$SOCKETFILTERFW" --add        /usr/local/bin/hostip
"$SOCKETFILTERFW" --unblockapp /usr/local/bin/hostip
