#! /bin/sh

exec 2>/dev/null

/bin/mkdir -p '/Library/Application Support/DNSCrypt/control'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/dnscrypt-proxy'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/probes'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/states'
/usr/sbin/chown -R 0:0 '/Library/Application Support/DNSCrypt'
/bin/chmod 710 '/Library/Application Support/DNSCrypt'

eval $(/usr/bin/stat -s '/dev/console')
if [ $? != 0 ]; then
  wanted_uid="$st_uid"
  /usr/sbin/chown -R "${wanted_uid}:0" '/Library/Application Support/DNSCrypt/control'
fi

/bin/launchctl load -D local
/bin/launchctl start com.opendns.osx.DNSCryptConsoleChange
/bin/launchctl start com.opendns.osx.DNSCryptControlChange
/bin/launchctl start com.opendns.osx.DNSCryptNetworkChange

/usr/bin/touch '/Library/Application Support/DNSCrypt/control'

exit 0
