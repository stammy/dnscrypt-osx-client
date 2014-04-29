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
FALLBACK_FILE="${CONTROL_DIR}/fallback"
HANDLERS_LOCK_FILE="${DNSCRYPT_VAR_RUN_BASE_DIR}/dnscrypt-handlers.lock"
DNSCRYPT_PROXY_PLUGINS_BASE_FILE="${CONTROL_DIR}/plugin"
STATIC_RESOLVERS_FILE="${CONTROL_DIR}/static-resolvers"

DEBUG_ENABLED_FILE="${CONTROL_DIR}/debug.enabled"

PLUGINS_ENABLED_FILE="${CONTROL_DIR}/plugins.enabled"
QUERY_LOGGING_FILE="${CONTROL_DIR}/plugin-query-logging.enabled"
BLOCKING_FILE="${CONTROL_DIR}/plugin-blocking.enabled"

QUERY_LOG_FILE="${DNSCRYPT_LOG_BASE_DIR}/dnscrypt-query.log"
DEBUG_LOG_FILE="${DNSCRYPT_LOG_BASE_DIR}/dnscrypt-osxclient-debug.log"
DEBUG_LOG_FILE_LOCK="${DEBUG_LOG_FILE}.lock"

BLACKLIST_IPS_FILE="${CONTROL_DIR}/blacklist-ips"
BLACKLIST_IPS_TMP_FILE="${BLACKLIST_IPS_FILE}.tmp"
BLACKLIST_DOMAINS_FILE="${CONTROL_DIR}/blacklist-domains"
BLACKLIST_DOMAINS_TMP_FILE="${BLACKLIST_DOMAINS_FILE}.tmp"
EXCEPTIONS_FILE="${CONTROL_DIR}/exceptions"
EXCEPTIONS_TMP_FILE="${EXCEPTIONS_FILE}.tmp"

DEFAULT_RESOLVER_NAME='opendns'

INTERFACE_UNBOUND="127.0.0.53"
INTERFACE_UNBOUND_MASK="24"
INTERFACE_PROXY="127.0.0.54"
INTERFACE_PROXY_MASK="24"
INTERFACE_PROBES="127.0.0.55"
INTERFACE_PROBES_MASK="24"

DOMAINS_EXCEPTIONS='
freebox.fr fritz.box intranet lan localdomain nowtv.com private routerlogin.net l
'

DISABLE_IPV6='no'

export PATH="${DNSCRYPT_USR_BASE_DIR}/bin:${DNSCRYPT_USR_BASE_DIR}/scripts:$PATH"

init_interfaces() {
  /sbin/ifconfig lo0 alias ${INTERFACE_UNBOUND}/${INTERFACE_UNBOUND_MASK}
  /sbin/ifconfig lo0 alias ${INTERFACE_PROXY}/${INTERFACE_PROXY_MASK}
  /sbin/ifconfig lo0 alias ${INTERFACE_PROBES}/${INTERFACE_PROBES_MASK}
}

logger_debug() {
  [ -f "$DEBUG_ENABLED_FILE" ] || return
  local msg="$1"
  local now="$(date)"
  lockfile "$DEBUG_LOG_FILE_LOCK" -1 -r 1 -l 5
  echo "$now - $msg" >> "$DEBUG_LOG_FILE"
  rm -f "$DEBUG_LOG_FILE_LOCK"
}
