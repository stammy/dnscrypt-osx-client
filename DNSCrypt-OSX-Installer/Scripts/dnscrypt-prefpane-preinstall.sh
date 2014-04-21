#! /bin/sh

exec 2>/dev/null

if [ -x /usr/bin/pkill ]; then
  /usr/bin/pkill -f '/Applications/System Preferences.app'
fi

/bin/rm -rf '/Library/Application Support/DNSCrypt Updater'

/bin/launchctl remove com.opendns.osx.DNSCryptConfigUpdater
/bin/rm -f '/Library/LaunchDaemons/com.opendns.osx.DNSCryptConfigUpdater.plist'

/bin/launchctl remove com.opendns.osx.DNSCryptAfterboot
/bin/launchctl remove com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl remove com.opendns.osx.DNSCryptControlChange
/bin/launchctl remove com.opendns.osx.DNSCryptNetworkChange
/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCrypt*.plist

/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptConfigUpdater
/bin/rm -f '/Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptConfigUpdater.plist'

/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptAfterboot
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptConsoleChange
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptControlChange
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptNetworkChange

/bin/rm -f /var/run/dnscrypt*.lock

exit 0
