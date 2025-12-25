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
fi

if [[ ! -z "${MAILBOX_TRANSPORT}" ]]; then
  add_config_value "mailbox_transport" "${MAILBOX_TRANSPORT}"
fi

add_config_value "mydomain" ${DOMAIN}
add_config_value "myorigin" ${DOMAIN}

add_config_value "maillog_file" "/dev/stdout"
add_config_value "smtp_host_lookup" "native,dns"
add_config_value "inet_protocols" "ipv4"
add_config_value "recipient_delimiter" "+"
add_config_value "always_add_missing_headers" "${ALWAYS_ADD_MISSING_HEADERS:-no}"
add_config_value "readme_directory" "${README_DIRECTORY:-no}"

cat /etc/postfix/main.cf

rm -f /var/spool/postfix/pid/master.pid

echo "Start postfix..."
exec /usr/sbin/postfix -c /etc/postfix start-fg
