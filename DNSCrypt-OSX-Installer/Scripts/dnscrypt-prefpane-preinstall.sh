#! /bin/sh

exec 2>/dev/null

/bin/launchctl remove com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl remove com.opendns.osx.DNSCryptControlChange
/bin/launchctl remove com.opendns.osx.DNSCryptNetworkChange

rm -f /var/run/dnscrypt*.lock

exit 0
