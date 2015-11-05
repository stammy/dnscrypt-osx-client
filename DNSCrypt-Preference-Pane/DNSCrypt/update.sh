#! /bin/sh

mkdir -p extra/usr/bin
cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/bin/hostip \
   extra/usr/bin/

mkdir -p extra/usr/sbin
cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/sbin/dnscrypt-proxy \
   extra/usr/sbin/
   
mkdir -p extra/usr/lib

cp /opt/ldns/lib/libldns.1.dylib \
   extra/usr/lib/
( cd extra/usr/lib &&
  ln -fs libldns.1.dylib libldns.dylib )

cp /usr/local/lib/libsodium.17.dylib \
   extra/usr/lib/
( cd extra/usr/lib &&
  ln -fs libsodium.17.dylib libsodium.dylib )

mkdir -p extra/usr/lib/dnscrypt-proxy

cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/lib/dnscrypt-proxy/* \
  extra/usr/lib/dnscrypt-proxy/

mkdir -p extra/usr/share/dnscrypt-proxy

cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/share/dnscrypt-proxy/dnscrypt-resolvers.csv \
  extra/usr/share/dnscrypt-proxy/
  
cp /Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr/share/dnscrypt-proxy/minisign.pub \
  extra/usr/share/dnscrypt-proxy/
