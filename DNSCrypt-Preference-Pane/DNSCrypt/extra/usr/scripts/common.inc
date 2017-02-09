
CURRENT_VERSION=7

DNSCRYPT_USR_BASE_DIR='/Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr'
DNSCRYPT_VAR_BASE_DIR='/Library/Application Support/DNSCrypt'
DNSCRYPT_LOG_BASE_DIR='/var/log'
DNSCRYPT_VAR_RUN_BASE_DIR='/var/run'

cd -- "${DNSCRYPT_USR_BASE_DIR}/scripts" || exit 1

CONTROL_DIR="${DNSCRYPT_VAR_BASE_DIR}/control"
TICKETS_DIR="${DNSCRYPT_VAR_BASE_DIR}/tickets"
DNSCRYPT_PROXY_BASE_DIR="${DNSCRYPT_VAR_BASE_DIR}/dnscrypt-proxy"
PROXY_PID_FILE="${DNSCRYPT_VAR_RUN_BASE_DIR}/dnscrypt-proxy.pid"
STATES_DIR="${DNSCRYPT_VAR_BASE_DIR}/states"

DNSCRYPT_RESOLVER_NAME_FILE="${CONTROL_DIR}/dnscrypt-resolver-name"
DNSCRYPT_FILE="${CONTROL_DIR}/dnscrypt"
HANDLERS_LOCK_FILE="${DNSCRYPT_VAR_RUN_BASE_DIR}/dnscrypt-handlers.lock"
DNSCRYPT_PROXY_PLUGINS_BASE_FILE="${CONTROL_DIR}/plugin"
STATIC_RESOLVERS_FILE="${CONTROL_DIR}/static-resolvers"
BLOCKED_QUERY_LOGGING_FILE="${CONTROL_DIR}/blocked-query-logging"

DEBUG_ENABLED_FILE="${CONTROL_DIR}/debug.enabled"

PLUGINS_ENABLED_FILE="${CONTROL_DIR}/plugins.enabled"
CACHE_FILE="${CONTROL_DIR}/plugin-cache.enabled"
QUERY_LOGGING_FILE="${CONTROL_DIR}/plugin-query-logging.enabled"
BLOCKING_FILE="${CONTROL_DIR}/plugin-blocking.enabled"
AAAA_BLOCKING_FILE="${CONTROL_DIR}/plugin-aaaa-blocking.enabled"
FORWARDING_FILE="${CONTROL_DIR}/plugin-forwarding.enabled"

BLOCKED_QUERY_LOG_FILE="${DNSCRYPT_LOG_BASE_DIR}/dnscrypt-blocked-query.log"
QUERY_LOG_FILE="${DNSCRYPT_LOG_BASE_DIR}/dnscrypt-query.log"
DEBUG_LOG_FILE="${DNSCRYPT_LOG_BASE_DIR}/dnscrypt-osxclient-debug.log"
DEBUG_LOG_FILE_LOCK="${DEBUG_LOG_FILE}.lock"

BLACKLIST_IPS_FILE="${CONTROL_DIR}/blacklist-ips"
BLACKLIST_IPS_TMP_FILE="${BLACKLIST_IPS_FILE}.tmp"
BLACKLIST_DOMAINS_FILE="${CONTROL_DIR}/blacklist-domains"
BLACKLIST_DOMAINS_TMP_FILE="${BLACKLIST_DOMAINS_FILE}.tmp"
EXCEPTIONS_FILE="${CONTROL_DIR}/exceptions"
EXCEPTIONS_TMP_FILE="${EXCEPTIONS_FILE}.tmp"

APP_UPDATES_BASE_URL="http://updates.dnscrypt.org/updates/dnscrypt-osx-client"
APP_UPDATES_DIR="${DNSCRYPT_VAR_BASE_DIR}/updates"
APP_UPDATES_PUBLIC_KEY="RWRvw8aArS/yEI3In0/zQSb9+qfWonLxjjEYG17cXt6zct6GLKtEvUfk"
APP_UPDATES_STATE="${APP_UPDATES_DIR}/app-updated"

RESOLVERS_UPDATES_BASE_URL="http://updates.dnscrypt.org/dnscrypt-proxy"
RESOLVERS_LIST_BASE_DIR="${DNSCRYPT_USR_BASE_DIR}/share/dnscrypt-proxy"
RESOLVERS_LIST_PUBLIC_KEY="RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3"
RESOLVERS_LIST_STATE="${STATES_DIR}/resolvers-updated"

INTERFACE_PROXY="127.0.0.54"
INTERFACE_PROXY_MASK="24"

export PATH="${DNSCRYPT_USR_BASE_DIR}/sbin:${DNSCRYPT_USR_BASE_DIR}/bin:${DNSCRYPT_USR_BASE_DIR}/scripts:$PATH"

init_interfaces() {
  /sbin/ifconfig lo0 alias ${INTERFACE_PROXY}/${INTERFACE_PROXY_MASK}
}

logger_debug() {
  [ -f "$DEBUG_ENABLED_FILE" ] || return
  lockfile -1 -r 1 "$DEBUG_LOG_FILE_LOCK" > /dev/null 2>&1
  echo "$(date) - $1" >> "$DEBUG_LOG_FILE"
  rm -f "$DEBUG_LOG_FILE_LOCK" 2> /dev/null
}
