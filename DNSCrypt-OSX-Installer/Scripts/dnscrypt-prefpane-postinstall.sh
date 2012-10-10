#! /bin/sh

exec 2>/dev/null

/bin/mkdir -p '/Library/Application Support/DNSCrypt/control'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/dnscrypt-proxy'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/probes'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/states'
/bin/mkdir -p '/Library/Application Support/DNSCrypt/tickets'
/bin/chmod 755 '/Library/Application Support/DNSCrypt'
/bin/chmod 755 '/usr/local/bin/hostip'
/bin/chmod 755 '/usr/local/sbin/dnscrypt-proxy'
/bin/chmod -R 755 '/usr/local/lib/dnscrypt-proxy'
/usr/sbin/chown -R 0:0 '/Library/Application Support/DNSCrypt'
/usr/sbin/chown 0:0 '/usr/local/bin/hostip'
/usr/sbin/chown 0:0 '/usr/local/lib/dnscrypt-proxy'
/usr/sbin/chown -R 0:0 '/usr/local/sbin/dnscrypt-proxy'

eval $(/usr/bin/stat -s '/dev/console')
if [ $? != 0 ]; then
  wanted_uid="$st_uid"
  /usr/sbin/chown -R "${wanted_uid}:0" \
    '/Library/Application Support/DNSCrypt/control'
  /usr/sbin/chown -R "${wanted_uid}:0" \
    '/Library/Application Support/DNSCrypt/tickets'
fi

rm -f '/Library/Application Support/DNSCrypt/control/plugin-parental-controls.enabled'
rm -f '/Library/Application Support/DNSCrypt/control/plugin-lockin.enabled'

for service in com.opendns.osx.DNSCryptAfterboot \
               com.opendns.osx.DNSCryptConsoleChange \
               com.opendns.osx.DNSCryptControlChange \
               com.opendns.osx.DNSCryptNetworkChange; do
  /bin/launchctl load "/Library/LaunchDaemons/${service}.plist"
  /bin/launchctl start "$service"
done

/usr/bin/touch '/Library/Application Support/DNSCrypt/control'

exit 0
