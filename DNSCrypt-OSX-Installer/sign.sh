#! /bin/sh

VERSION='1.0.7'

cd build || exit 1
[ -e DNSCrypt.pkg ] || exit 1

rm -fr DNSCrypt-OSX.pkg DNSCrypt-unsigned.pkg

productsign --sign 'Developer ID Installer' DNSCrypt.pkg DNSCrypt-OSX.pkg

mv DNSCrypt.pkg DNSCrypt-unsigned.pkg
mv DNSCrypt-OSX.pkg DNSCrypt.pkg

zip -9 -r "dnscrypt-osxclient-${VERSION}.zip" DNSCrypt.pkg
rm -fr dnscrypt-pkg
rm -f "dnscrypt-osxclient-${VERSION}.dmg"
mkdir dnscrypt-pkg
mv DNSCrypt.pkg dnscrypt-pkg
hdiutil create "dnscrypt-osxclient-${VERSION}.dmg" -srcfolder dnscrypt-pkg

mv dnscrypt-pkg/DNSCrypt.pkg .
rm -fr dnscrypt-pkg
rm -fr DNSCrypt-unsigned.pkg
