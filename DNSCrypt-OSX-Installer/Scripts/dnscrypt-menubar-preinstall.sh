#! /bin/sh

exec 2>/dev/null

/bin/launchctl stop com.opendns.osx.DNSCryptMenuBar
/bin/launchctl remove com.opendns.osx.DNSCryptMenuBar

exit 0
