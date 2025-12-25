#!/bin/bash

docker run -e MESSAGE_SIZE_LIMIT=1111 -e SHOW_MAIN_CF=yes -e RDBMS_ENABLED=yes -e RDBMS_TYPENAME=postgres -p 25:25 volnenko/postfix-lmtp:latest