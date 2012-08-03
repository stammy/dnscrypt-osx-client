#! /bin/sh

exec 2>/dev/null

/bin/launchctl load \
  '/Library/LaunchAgents/com.opendns.osx.DNSCryptMenuBar.plist'

/bin/launchctl start com.opendns.osx.DNSCryptMenuBar

exit 0
