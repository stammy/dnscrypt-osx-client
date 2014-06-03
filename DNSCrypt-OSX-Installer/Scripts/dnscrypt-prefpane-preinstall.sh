#! /bin/sh

exec 2>/dev/null

killall 'System Preferences'

/bin/rm -rf '/Library/Application Support/DNSCrypt Updater'

/bin/launchctl stop com.opendns.osx.DNSCryptConfigUpdater
/bin/launchctl remove com.opendns.osx.DNSCryptConfigUpdater
/bin/rm -f '/Library/LaunchDaemons/com.opendns.osx.DNSCryptConfigUpdater.plist'

/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptConfigUpdater
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptConfigUpdater
/bin/rm -f '/Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptConfigUpdater.plist'

/bin/launchctl stop com.opendns.osx.DNSCryptAfterboot
/bin/launchctl remove com.opendns.osx.DNSCryptAfterboot
/bin/launchctl stop com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl remove com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl stop com.opendns.osx.DNSCryptControlChange
/bin/launchctl remove com.opendns.osx.DNSCryptControlChange
/bin/launchctl stop com.opendns.osx.DNSCryptNetworkChange
/bin/launchctl remove com.opendns.osx.DNSCryptNetworkChange

/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCryptAfterboot.plist
/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCryptConsoleChange.plist
/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCryptControlChange.plist
/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCryptNetworkChange.plist

/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptAfterboot
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptAfterboot
/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptConsoleChange
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptConsoleChange
/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptControlChange
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptControlChange
/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptNetworkChange
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptNetworkChange

/bin/rm -f /Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptAfterboot.plist
/bin/rm -f /Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptConsoleChange.plist
/bin/rm -f /Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptControlChange.plist
/bin/rm -f /Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptNetworkChange.plist

/bin/rm -f /var/run/dnscrypt*.lock

exit 0
