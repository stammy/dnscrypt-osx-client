#! /bin/sh

VERSION='1.0.12'

echo '*** Do not forget to increase CURRENT_VERSION in common.inc'
sleep 10

cd build || exit 1
[ -e DNSCrypt.pkg ] || exit 1

rm -fr DNSCrypt-OSX.pkg DNSCrypt-unsigned.pkg

productsign --sign 'Developer ID Installer' DNSCrypt.pkg DNSCrypt-OSX.pkg

mv DNSCrypt.pkg DNSCrypt-unsigned.pkg
mv DNSCrypt-OSX.pkg DNSCrypt.pkg

rm -fr dnscrypt-pkg
rm -f "dnscrypt-osxclient-${VERSION}.dmg"
mkdir dnscrypt-pkg
mv DNSCrypt.pkg dnscrypt-pkg
hdiutil create "dnscrypt-osxclient-${VERSION}.dmg" -srcfolder dnscrypt-pkg

mv dnscrypt-pkg/DNSCrypt.pkg .
rm -fr dnscrypt-pkg
rm -fr DNSCrypt-unsigned.pkg

minisign -S -m "dnscrypt-osxclient-${VERSION}.dmg" \
  -p ../../minisign.pub -s ../../minisign.key \
  -t "dnscrypt-osxclient-${VERSION}.dmg"
