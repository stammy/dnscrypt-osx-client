#! /bin/sh

exec 2>/dev/null

mkdir -p '/Library/Application Support/DNSCrypt/control'
mkdir -p '/Library/Application Support/DNSCrypt/dnscrypt-proxy'
mkdir -p '/Library/Application Support/DNSCrypt/probes'
mkdir -p '/Library/Application Support/DNSCrypt/states'
chown -R 0:0 '/Library/Application Support/DNSCrypt'
chmod 710 '/Library/Application Support/DNSCrypt'

eval $(stat -s '/dev/console') || exit 1
wanted_uid="$st_uid"
chown -R "${wanted_uid}:0" '/Library/Application Support/DNSCrypt/control'

/bin/launchctl load -D local
/bin/launchctl start com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl start com.opendns.osx.DNSCryptControlChange
/bin/launchctl start com.opendns.osx.DNSCryptNetworkChange

touch '/Library/Application Support/DNSCrypt/control'

exit 0
