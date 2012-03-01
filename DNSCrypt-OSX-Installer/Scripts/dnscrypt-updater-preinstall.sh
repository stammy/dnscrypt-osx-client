#! /bin/sh

exec 2>/dev/null

/bin/launchctl remove com.opendns.osx.DNSCryptConfigUpdater
i=0
while [ "$i" -lt 5 ]; do
  sleep 1
  fgrep 127.0.0.1 /etc/resolv.conf > /dev/null || exit 0
  i=$((i+1))
done
rm -f /var/run/com.opendns.osx.DNSCryptConfigUpdater/sock

exit 0
