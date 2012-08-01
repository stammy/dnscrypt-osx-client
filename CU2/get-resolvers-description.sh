#! /bin/sh

. ./common.inc

if [ -e "${STATES_DIR}/updating" ]; then
  echo 'Updating'
  exit 0
fi
name='None'
level=0
while read resolver; do
  case "$resolver" in
    208.67.222.123|208.67.220.123)
      if [ $level -le 70 ]; then
        name='FamilyShield'
        level=70
      fi
    ;;
    208.67.*)
      if [ $level -le 40 ]; then
        name='OpenDNS'
        level=40
      fi
    ;;
    2620:0:*)
      if [ $level -le 50 ]; then
        name='OpenDNS IPv6'
        level=50
      fi
    ;;
    127.0.0.5*)
      if [ $level -le 80 ]; then
        name='DNSCrypt'
        level=80
      fi
    ;;
    127.0.0.1)
      if [ $level -le 20 ]; then
        name='Localhost'
        level=20
      fi
    ;;
    ::1)
      if [ $level -le 30 ]; then
        name='Localhost IPv6'
        level=30
      fi
    ;;
    *)
      if [ $level -le 10 ]; then
        name='Insecure'
        level=10
      fi
    ;;
  esac
done
echo "$name"
