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
        name='Default'
        level=10
      fi
    ;;
  esac
done
echo "$name"
