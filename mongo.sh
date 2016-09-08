#!/usr/bin/env bash

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh


echo "Connecting to database of ${SERVER_NAME}..."
mongo ${MONGO_URL}