#! /bin/sh

VERSION='0.18'

cd build || exit 1
[ -d DNSCrypt.mpkg ] || exit 1

(
cd DNSCrypt.mpkg/Contents/Packages || exit 1

for pkg in *pkg ; do
  rm -fr "x-${pkg}"
  mv "$pkg" "x-${pkg}"
  productsign --sign 'Developer ID Installer' "x-${pkg}" "$pkg"
  rm -fr "x-${pkg}"
done
)
rm -fr DNSCrypt-OSX.mpkg DNSCrypt-unsigned.mpkg
productsign --sign 'Developer ID Application' DNSCrypt.mpkg DNSCrypt-OSX.mpkg
mv DNSCrypt.mpkg DNSCrypt-unsigned.mpkg
mv DNSCrypt-OSX.mpkg DNSCrypt.mpkg
zip -9 -r "dnscrypt-osx-client-${VERSION}.zip" DNSCrypt.mpkg
rm -fr dnscrypt-pkg
rm -f "dnscrypt-osx-client-${VERSION}.dmg"
mkdir dnscrypt-pkg
mv DNSCrypt.mpkg dnscrypt-pkg
hdiutil create "dnscrypt-osx-client-${VERSION}.dmg" -srcfolder dnscrypt-pkg

mv dnscrypt-pkg/DNSCrypt.mpkg .
rm -fr dnscrypt-pkg
rm -fr DNSCrypt-unsigned.mpkg
