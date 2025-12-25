FROM registry.volnenko.ru/library/ubuntu:22.04

RUN apt update
RUN apt install -y postfix postfix-pgsql mailutils-mda
RUN apt install -y mc telnet

ADD ./src/opt/postfix/run.sh /opt/postfix/run.sh

EXPOSE 25
WORKDIR /opt/postfix

CMD ["/opt/postfix/run.sh"]