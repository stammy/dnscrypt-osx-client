#! /bin/sh

exec 2>/dev/null

/bin/launchctl remove com.opendns.osx.RoamingClientMenubar
/bin/launchctl remove com.opendns.osx.RoamingClientConfigUpdater
/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.Roaming*.plist

/bin/launchctl stop com.opendns.osx.DNSCryptMenuBar
/bin/launchctl remove com.opendns.osx.DNSCryptMenuBar

exit 0
