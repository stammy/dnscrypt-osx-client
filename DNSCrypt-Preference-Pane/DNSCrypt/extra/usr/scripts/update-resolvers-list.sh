#! /bin/sh

. ./common.inc

DNSCRYPT_LIB_BASE_DIR="${DNSCRYPT_USR_BASE_DIR}/lib"
export DYLD_LIBRARY_PATH="${DNSCRYPT_LIB_BASE_DIR}:${DYLD_LIBRARY_PATH}"

logger_debug "Checking if updates to the resolvers list are available"

curl -L --max-redirs 5 -4 -m 30 --connect-timeout 30 -s \
  "${RESOLVERS_UPDATES_BASE_URL}/dnscrypt-resolvers.csv" > \
  "${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv.tmp" &&
curl -L --max-redirs 5 -4 -m 30 --connect-timeout 30 -s \
  "${RESOLVERS_UPDATES_BASE_URL}/dnscrypt-resolvers.csv.minisig" > \
  "${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv.minisig" &&
minisign-verify -Vm ${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv.tmp \
  -x "${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv.minisig" \
  -P "$RESOLVERS_LIST_PUBLIC_KEY" -q &&
mv -f ${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv.tmp \
  ${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv

logger_debug "Resolvers list is up to date"
