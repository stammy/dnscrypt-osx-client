#! /bin/sh

exec 2>/dev/null

/bin/launchctl stop com.opendns.osx.RoamingClientMenubar
/bin/launchctl remove com.opendns.osx.RoamingClientMenubar

/bin/launchctl stop com.opendns.osx.RoamingClientConfigUpdater
/bin/launchctl remove com.opendns.osx.RoamingClientConfigUpdater

/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.Roaming*.plist

/bin/launchctl stop com.opendns.osx.DNSCryptMenuBar
/bin/launchctl remove com.opendns.osx.DNSCryptMenuBar

/bin/launchctl stop com.github.dnscrypt-osxclient.DNSCryptMenuBar
/bin/launchctl remove com.github.dnscrypt-osxclient.DNSCryptMenuBar

killall 'DNSCrypt-Menubar'
killall 'DNSCrypt Menubar'

/bin/rm -f /Library/LaunchDaemons/com.opendns.osx.DNSCryptMenuBar.plist
/bin/rm -f /Library/LaunchDaemons/com.github.dnscrypt-osxclient.DNSCryptMenuBar.plist

exit 0
