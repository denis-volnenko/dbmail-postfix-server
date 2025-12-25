#!/bin/bash

docker run -e MESSAGE_SIZE_LIMIT=1111 -p 25:25 volnenko/postfix-lmtp:latest