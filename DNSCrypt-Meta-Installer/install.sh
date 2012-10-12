#! /bin/sh

env > /tmp/a
tdir=$(mktemp -d /tmp/XXXXXXXXXXXXXXXX)
chmod 755 "$tdir"
tar x -z -C "$tdir" -f pkg.tgz
(sleep 10 ; cd "$tdir" ; exec open -W -b 'com.apple.installer' ./DNSCrypt.mpkg) &
