#! /bin/sh

name='Insecure'
while read resolver; do
  case "$resolver" in
    208.67.222.123|208.67.220.123)
      name='FamilyShield' ;;
    208.67.*)
      name='OpenDNS' ;;
    2620:0:*)
      name='OpenDNS IPv6' ;;
    127.0.0.5*)
      name='DNSCrypt' ;;
    127.0.0.1)
      name='Localhost' ;;
    ::1)
      name='Localhost IPv6' ;;
  esac
done
echo $name
