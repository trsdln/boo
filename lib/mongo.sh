#!/usr/bin/env bash

# source common part
. ${1}/common.sh


echo "Connecting to database of ${SERVER_NAME}..."
mongo ${MONGO_URL}
