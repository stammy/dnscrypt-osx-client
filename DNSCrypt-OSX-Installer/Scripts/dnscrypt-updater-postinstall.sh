#! /bin/sh

exec 2>/dev/null

chown root:admin '/Library/Application Support/DNSCrypt Updater'
chmod 710 '/Library/Application Support/DNSCrypt Updater'
/bin/launchctl load -D local
/bin/launchctl start com.opendns.osx.DNSCryptConfigUpdater

exit 0
