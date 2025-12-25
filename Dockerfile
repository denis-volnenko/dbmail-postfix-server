FROM registry.volnenko.ru/library/ubuntu:22.04

RUN apt update
RUN apt install -y postfix postfix-pgsql mailutils-mda
RUN apt install -y mc telnet

ADD ./src/etc/mailname /etc/mailname
ADD ./src/opt/postfix/run.sh /opt/postfix/run.sh
ADD ./src/etc/postfix/sql_virtual_mailbox_domains/main.cf /etc/postfix/sql_virtual_mailbox_domains/main.cf
ADD ./src/etc/postfix/sql_virtual_mailbox_maps/main.cf /etc/postfix/sql_virtual_mailbox_maps/main.cf

EXPOSE 25
WORKDIR /opt/postfix

CMD ["/opt/postfix/run.sh"]