#! /bin/sh

mkdir -p extra/usr/bin
cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/bin/hostip \
   extra/usr/bin/

nd=$(otool -L /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/sbin/dnscrypt-proxy | wc -l)
if [ $nd -gt 2 ]; then
  echo '*** dnscrypt-proxy may have more dependencies than libSystem.B.dylib'
  echo '*** make sure that libsodium was statically linked'
  sleep 10
fi

nd=$(otool -L /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/lib/dnscrypt-proxy/libdcplugin_example_ldns_aaaa_blocking.so | wc -l)
if [ $nd -gt 3 ]; then
  echo '*** plugins may have more dependencies than libSystem.B.dylib and ldns'
  echo '*** make sure that they were linked against ldns compiled without SSL'
  sleep 10
fi

mkdir -p extra/usr/sbin
cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/sbin/dnscrypt-proxy \
   extra/usr/sbin/

mkdir -p extra/usr/lib

cp /opt/ldns/lib/libldns.2.dylib \
   extra/usr/lib/
( cd extra/usr/lib &&
  rm -f libldns.dylib &&
  ln -fs libldns.2.dylib libldns.dylib )

if [ -f /usr/local/lib/libsodium.18.dylib ]; then
  echo '*** /usr/local/lib/libsodium.{dylib,la} found'
  echo '*** Compile dnscrypt-proxy without them to get a static build'
  echo '*** Then reinstall them'
  sleep 10
fi

cp /usr/local/lib/libsodium.18.dylib \
   extra/usr/lib/
( cd extra/usr/lib &&
  rm -f libsodium.dylib &&
  ln -fs libsodium.18.dylib libsodium.dylib )

mkdir -p extra/usr/lib/dnscrypt-proxy

cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/lib/dnscrypt-proxy/* \
  extra/usr/lib/dnscrypt-proxy/

mkdir -p extra/usr/share/dnscrypt-proxy

cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv \
  extra/usr/share/dnscrypt-proxy/

cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/share/dnscrypt-proxy/minisign.pub \
  extra/usr/share/dnscrypt-proxy/
