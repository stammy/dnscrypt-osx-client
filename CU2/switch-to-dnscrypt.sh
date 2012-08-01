#! /bin/sh

. ./common.inc

touch "$DNSCRYPT_FILE"
exec ./switch-to-dnscrypt-if-required.sh
