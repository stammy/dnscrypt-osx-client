#! /bin/sh

exec 2>/dev/null

/bin/launchctl load \
  '/Library/LaunchAgents/com.github.dnscrypt-osxclient.DNSCryptMenuBar.plist'

/bin/launchctl start com.github.dnscrypt-osxclient.DNSCryptMenuBar

exit 0
