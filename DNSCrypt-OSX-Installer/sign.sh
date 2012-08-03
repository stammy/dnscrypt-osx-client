#! /bin/sh

VERSION='0.12-dev'

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
zip -9 -r "dnscrypt-osx-gui-${VERSION}.zip" DNSCrypt-OSX.mpkg
