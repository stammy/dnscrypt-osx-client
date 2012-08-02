#! /bin/sh

exec 2>/dev/null

/bin/launchctl load -D local -S Aqua
/bin/launchctl start com.opendns.osx.DNSCryptMenuBar

exit 0
