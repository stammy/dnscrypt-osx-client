#! /bin/sh

. ./common.inc

DNSCRYPT_LIB_BASE_DIR="${DNSCRYPT_USR_BASE_DIR}/lib"
export DYLD_LIBRARY_PATH="${DNSCRYPT_LIB_BASE_DIR}:${DYLD_LIBRARY_PATH}"

TARGET_DIR=~/Desktop

[ -e "$APP_UPDATES_STATE" ] && exit 0
touch "$APP_UPDATES_STATE" || exit 1

[ -d "$TARGET_DIR" ] || exit 1
mkdir -p "$APP_UPDATES_DIR" || exit 1

curl -L --max-redirs 5 -4 -m 30 --connect-timeout 30 -s \
    "${APP_UPDATES_BASE_URL}/versions.txt" > "${APP_UPDATES_DIR}/versions.txt" || exit 1

CURRENT_HASH=$(shasum -a 512 "${APP_UPDATES_DIR}/versions.txt")
OLD_HASH=$(cat "${APP_UPDATES_DIR}/versions_hash" 2> /dev/null)
[ "x$CURRENT_HASH" = "x$OLD_HASH" ] && exit 0

curl -L --max-redirs 5 -4 -m 30 --connect-timeout 30 -s \
    "${APP_UPDATES_BASE_URL}/versions.txt.minisig" > "${APP_UPDATES_DIR}/versions.txt.minisig" || exit 1

minisign-verify -q -V -P "$APP_UPDATES_PUBLIC_KEY" -m "${APP_UPDATES_DIR}/versions.txt" || exit 1
rm -f "${APP_UPDATES_DIR}/versions.txt.minisig"

OS_VERSION=$(sw_vers -productVersion | sed 's/[^0-9.]$//' | cut -d. -f1-2) || exit 0
AVAILABLE=$(egrep "^${OS_VERSION} " "${APP_UPDATES_DIR}/versions.txt") || exit 0
rm -f "${APP_UPDATES_DIR}/versions.txt"
AVAILABLE_VERSION=$(echo "$AVAILABLE" | cut -d' ' -f2 | sed 's/[^0-9]//g')
DOWNLOAD_URL=$(echo "$AVAILABLE" | cut -d' ' -f3 | sed 's/ //g')
DOWNLOADED_FILE="${TARGET_DIR}/dnscrypt-update-${AVAILABLE_VERSION}.dmg"
[ -f "$DOWNLOADED_FILE" ] && exit 0
[ -z "$AVAILABLE_VERSION" -o -z "$DOWNLOAD_URL" ] && exit 1
[ "$AVAILABLE_VERSION" -gt "$CURRENT_VERSION" ] || exit 0
SIG_DOWNLOAD_URL="${DOWNLOAD_URL}.minisig"

curl -L --max-redirs 5 -4 -m 30 --connect-timeout 30 -s \
    "$SIG_DOWNLOAD_URL" > "${APP_UPDATES_DIR}/update.tmp.minisig" || exit 1

curl -L --max-redirs 5 -4 -m 300 --connect-timeout 30 -s --compress \
    "$DOWNLOAD_URL" > "${APP_UPDATES_DIR}/update.tmp" || exit 1

minisign-verify -q -V -P "$APP_UPDATES_PUBLIC_KEY" -m "${APP_UPDATES_DIR}/update.tmp" || exit 1
rm -f "${APP_UPDATES_DIR}/update.tmp.minisig"

mv -f "${APP_UPDATES_DIR}/update.tmp" "$DOWNLOADED_FILE" || exit 1
echo "$CURRENT_HASH" > "${APP_UPDATES_DIR}/versions_hash"

osascript -e "display notification \"A new version of DNSCrypt has been downloaded and saved on your desktop. Install it whenever you want!\" with title \"A new version of DNSCrypt is available!\" sound name \"Hero\""
