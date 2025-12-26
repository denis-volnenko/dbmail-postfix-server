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

echo "${DOMAIN:-localhost}" >> /etc/mailname
add_config_value "mydomain" "${DOMAIN:-localhost}"
#add_config_value "myorigin" "${DOMAIN:-localhost}"
add_config_value "myhostname" "${SERVER_HOSTNAME:-localhost}"

if [[ ! -z "${MAILLOG_FILE}" ]]; then
  add_config_value "maillog_file" "${MAILLOG_FILE}"
else
  add_config_value "maillog_file" "/dev/stdout"
fi

if [[ ! -z "${SMTP_HOST_LOOKUP}" ]]; then
  add_config_value "smtp_host_lookup" "${SMTP_HOST_LOOKUP}"
else
  add_config_value "smtp_host_lookup" "native,dns"
fi

if [[ ! -z "${INET_PROTOCOLS}" ]]; then
  add_config_value "inet_protocols" "${INET_PROTOCOLS}"
else
  add_config_value "inet_protocols" "ipv4"
fi

if [[ ! -z "${RECIPIENT_DELIMITER}" ]]; then
  add_config_value "recipient_delimiter" "${RECIPIENT_DELIMITER}"
else
  add_config_value "recipient_delimiter" "+"
fi

if [[ ! -z "${ALWAYS_ADD_MISSING_HEADERS}" ]]; then
  add_config_valie "always_add_missing_headers" "yes"
else
  add_config_value "always_add_missing_headers" "no"
fi

if [[ "${README_DIRECTORY}" == "yes" ]]; then
  add_config_value "readme_directory" "yes"
else
  add_config_value "readme_directory" "no"
fi

if [[ "${APPEND_DOT_MYDOMAIN}" == "yes" ]]; then
  add_config_value "append_dot_mydomain" "yes"
else
  add_config_value "append_dot_mydomain" "no"
fi

if [[ ! -z "${SMTPD_SENDER_RESTRICTIONS}" ]]; then
  add_config_value "smtpd_sender_restrictions" "${SMTPD_SENDER_RESTRICTIONS}"
else
  add_config_value "smtpd_sender_restrictions" "permit_mynetworks, reject_non_fqdn_sender, reject_unknown_sender_domain, reject_unlisted_sender, reject_sender_login_mismatch, permit"
fi

if [[ ! -z "${SMTPD_RECIPIENT_RESTRICTIONS}" ]]; then
  add_config_value "smtpd_recipient_restrictions" "${SMTPD_RECIPIENT_RESTRICTIONS}"
else
  add_config_value "smtpd_recipient_restrictions" "reject_unauth_pipelining, reject_non_fqdn_recipient, permit_mynetworks, permit"
fi

if [[ "${SMTPUTF8_ENABLE}" == "yes" ]]; then
  postconf -e "smtputf8_enable = yes"
fi

if [[ "$SMTP_USE_TLS" == "yes" ]]; then
  add_config_value "smtp_use_tls" "yes"
else
  add_config_value "smtp_use_tls" "no"
fi

if [[ "${VIRTUAL_MAILBOX_DOMAINS}" == "yes" ]]; then
   if [[ "${RDBMS_TYPENAME}" == "postgres" ]]; then
     add_conf_value "virtual_mailbox_domains" "pgsql:/etc/postfix/sql_virtual_mailbox_domains/main.cf"
   fi
   if [[ "${RDBMS_TYPENAME}" == "mysql" ]]; then
     add_conf_value "virtual_mailbox_domains" "mysql:/etc/postfix/sql_virtual_mailbox_domains/main.cf"
   fi
fi

if [[ "${VIRTUAL_MAILBOX_MAPS}" == "yes" ]]; then
   if [[ "${RDBMS_TYPENAME}" == "postgres" ]]; then
     add_conf_value "virtual_mailbox_maps" "pgsql:/etc/postfix/sql_virtual_mailbox_maps/main.cf"
   fi
   if [[ "${RDBMS_TYPENAME}" == "mysql" ]]; then
     add_conf_value "virtual_mailbox_maps" "mysql:/etc/postfix/sql_virtual_mailbox_maps/main.cf"
   fi
fi

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
   if [[ "${RDBMS_TYPENAME}" == "mysql" ]]; then
      postconf -c "/etc/postfix/sql_virtual_mailbox_domains" -e "query = SELECT DISTINCT 1 FROM dbmail_aliases WHERE SUBSTRING_INDEX(alias, '@', -1) = '%s';"
      postconf -c "/etc/postfix/sql_virtual_mailbox_maps" -e "query = SELECT 1 FROM dbmail_aliases WHERE alias='%s';"
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

if [ ! -z "${SMTP_USERNAME}" ]; then
  add_config_value "smtp_sasl_auth_enable" "yes"
  add_config_value "smtp_sasl_password_maps" "lmdb:/etc/postfix/sasl_passwd"
  add_config_value "smtp_sasl_security_options" "noanonymous"
fi

if [ ! -f /etc/postfix/sasl_passwd -a ! -z "${SMTP_USERNAME}" ]; then
  grep -q "${SMTP_SERVER}" /etc/postfix/sasl_passwd  > /dev/null 2>&1
  if [ $? -gt 0 ]; then
    echo "Adding SASL authentication configuration"
    echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" >> /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
  fi
fi

rm -f /var/spool/postfix/pid/master.pid
exec /usr/sbin/postfix -c /etc/postfix start-fg
