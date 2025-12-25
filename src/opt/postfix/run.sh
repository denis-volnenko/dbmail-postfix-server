#!/bin/bash

function add_config_value() {
  local key=${1}
  local value=${2}
  # local config_file=${3:-/etc/postfix/main.cf}
  [ "${key}" == "" ] && echo "ERROR: No key set !!" && exit 1
  [ "${value}" == "" ] && echo "ERROR: No value set !!" && exit 1

  echo "Setting configuration option ${key} with value: ${value}"
 postconf -e "${key} = ${value}"
}


if [[ ! -z "${MESSAGE_SIZE_LIMIT}" ]]; then
  add_config_value "message_size_limit" "${MESSAGE_SIZE_LIMIT}"
else
  add_config_value "message_size_limit" "0"
fi

if [[ ! -z "${MY_DESTINATION}" ]]; then
  add_config_value "mydestination" "${MY_DESTINATION}"
fi

if [[ ! -z "${MY_NETWORKS}" ]]; then
  add_config_value "mynetworks" "${MY_NETWORKS}"
fi

if [[ ! -z "${VIRTUAL_TRANSPORT}" ]]; then
  add_config_value "virtual_transport" "${VIRTUAL_TRANSPORT}"
else
  add_config_value "virtual_transport" "lmtp:inet:localhost:24"
fi

if [[ ! -z "${MAILBOX_TRANSPORT}" ]]; then
  add_config_value "mailbox_transport" "${MAILBOX_TRANSPORT}"
else
  add_config_value "mailbox_transport" "lmtp:inet:localhost:24"
fi

add_config_value "mydomain" ${DOMAIN:-localhost}
add_config_value "myorigin" ${DOMAIN:-localhost}
add_config_value "myhostname" ${SERVER_HOSTNAME:-localhost}

add_config_value "maillog_file" "/dev/stdout"
add_config_value "smtp_host_lookup" "native,dns"
add_config_value "inet_protocols" "ipv4"
add_config_value "recipient_delimiter" "+"
add_config_value "always_add_missing_headers" "${ALWAYS_ADD_MISSING_HEADERS:-no}"
add_config_value "readme_directory" "${README_DIRECTORY:-no}"
add_config_value "append_dot_mydomain" "${APPEND_DOT_MYDOMAIN:-no}"

if [[ "${RDBMS_ENABLED}" == "yes" ]]; then
   postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "user = ${RDBMS_USERNAME:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "user = ${RDBMS_USERNAME:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "password = ${RDBMS_PASSWORD:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "password = ${RDBMS_PASSWORD:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "hosts = ${RDBMS_HOSTNAME:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "hosts = ${RDBMS_HOSTNAME:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "dbname = ${RDBMS_DATABASE:-}"
   postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "dbname = ${RDBMS_DATABASE:-}"
   if [[ "${RDBMS_TYPENAME}" == "postgres" ]]; then
      postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "query = SELECT DISTINCT 1 FROM dbmail_aliases WHERE SUBSTRING(alias FROM POSITION('@' in alias)+1) = '%s';"
      postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "query = SELECT DISTINCT 1  FROM dbmail_aliases WHERE alias= '%s';"
   fi
fi

if [[ "${SHOW_MAIN_CF}" == "yes" ]]; then
  echo "/etc/postfix/main.cf"
  cat /etc/postfix/main.cf
fi

if [[ "${SHOW_MASTER_CF}" == "yes" ]]; then
  echo "/etc/postfix/master.cf"
  cat /etc/postfix/master.cf
fi

rm -f /var/spool/postfix/pid/master.pid

echo "Start postfix..."
exec /usr/sbin/postfix -c /etc/postfix start-fg
