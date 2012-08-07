#! /bin/sh

VERSION='0.13'

cd build || exit 1
(
cd DNSCrypt.mpkg/Contents/Packages || exit 1

for pkg in *pkg; do
  rm -fr "x-${pkg}"
  mv "$pkg" "x-${pkg}"
  productsign --sign 'Developer ID Installer' "x-${pkg}" "$pkg"
  rm -fr "x-${pkg}"
done
)
rm -fr DNSCrypt-OSX.mpkg
productsign --sign 'Developer ID Application' DNSCrypt.mpkg DNSCrypt-OSX.mpkg
zip -9 -r "dnscrypt-osx-client-${VERSION}.zip" DNSCrypt-OSX.mpkg
rm -fr dstroot
rm -f "dnscrypt-osx-client-${VERSION}.dmg"
mkdir dstroot
mv DNSCrypt-OSX.mpkg dstroot
hdiutil create "dnscrypt-osx-client-${VERSION}.dmg" -srcfolder dstroot

mv dstroot/DNSCrypt-OSX.mpkg .
rm -fr dstroot
