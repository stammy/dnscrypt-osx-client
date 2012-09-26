
DNSCRYPT_USR_BASE_DIR='/Library/PreferencePanes/DNSCrypt.prefPane/Contents/Resources/usr'
DNSCRYPT_VAR_BASE_DIR='/Library/Application Support/DNSCrypt'

cd -- "${DNSCRYPT_USR_BASE_DIR}/scripts" || exit 1

CONTROL_DIR="${DNSCRYPT_VAR_BASE_DIR}/control"
TICKETS_DIR="${DNSCRYPT_VAR_BASE_DIR}/tickets"
DNSCRYPT_PROXY_BASE_DIR="${DNSCRYPT_VAR_BASE_DIR}/dnscrypt-proxy"
PROXY_PID_FILE="/var/run/dnscrypt-proxy.pid"
STATES_DIR="${DNSCRYPT_VAR_BASE_DIR}/states"

DNSCRYPT_FILE="${CONTROL_DIR}/dnscrypt"
FAMILYSHIELD_FILE="${CONTROL_DIR}/familyshield"
INSECURE_OPENDNS_FILE="${CONTROL_DIR}/insecure-opendns"
FALLBACK_FILE="${CONTROL_DIR}/fallback"
HANDLERS_LOCK_FILE="/var/run/dnscrypt-handlers.lock"
DOMAINS_EXCEPTIONS_FILE="${CONTROL_DIR}/domains-exceptions"
DNSCRYPT_PROXY_PLUGINS_BASE_FILE="${CONTROL_DIR}/plugin"
STATIC_RESOLVERS_FILE="${CONTROL_DIR}/static-resolvers"

PLUGINS_ENABLED_FILE="${CONTROL_DIR}/plugins.enabled"
PARENTAL_CONTROLS_FILE="${CONTROL_DIR}/plugin-parental-controls.enabled"
QUERY_LOGGING_FILE="${CONTROL_DIR}/plugin-query-logging.enabled"
LOCKIN_FILE="${CONTROL_DIR}/plugin-lockin.enabled"
BLOCKING_FILE="${CONTROL_DIR}/plugin-blocking.enabled"

QUERY_LOG_FILE="/var/log/dnscrypt-query.log"
BLACKLIST_IPS_FILE="${CONTROL_DIR}/blacklist-ips"
BLACKLIST_DOMAINS_FILE="${CONTROL_DIR}/blacklist-domains"

INTERFACE_UNBOUND="127.0.0.53"
INTERFACE_UNBOUND_MASK="24"
INTERFACE_PROXY="127.0.0.54"
INTERFACE_PROXY_MASK="24"
INTERFACE_PROBES="127.0.0.55"
INTERFACE_PROBES_MASK="24"

DOMAINS_EXCEPTIONS='
fritz.box intranet lan localdomain nowtv.com private routerlogin.net
'

export PATH="${DNSCRYPT_USR_BASE_DIR}/bin:${DNSCRYPT_USR_BASE_DIR}/scripts:$PATH"

init_interfaces() {
  sudo ifconfig lo0 alias ${INTERFACE_UNBOUND}/${INTERFACE_UNBOUND_MASK}
  sudo ifconfig lo0 alias ${INTERFACE_PROXY}/${INTERFACE_PROXY_MASK}
  sudo ifconfig lo0 alias ${INTERFACE_PROBES}/${INTERFACE_PROBES_MASK}
}
