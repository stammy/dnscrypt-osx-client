#! /bin/sh

exec 2>/dev/null

if [ -x /usr/bin/pkill ]; then
  /usr/bin/pkill -f '/Applications/System Preferences.app'
fi

/bin/launchctl remove com.opendns.osx.DNSCryptConfigUpdater
/bin/rm -f '/Library/LaunchDaemons/com.opendns.osx.DNSCryptConfigUpdater.plist'
/bin/rm -rf '/Library/Application Support/DNSCrypt Updater'

/bin/launchctl remove com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl remove com.opendns.osx.DNSCryptControlChange
/bin/launchctl remove com.opendns.osx.DNSCryptNetworkChange

/bin/rm -f /var/run/dnscrypt*.lock

exit 0
