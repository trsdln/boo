#!/bin/bash

#
# Arguments:
# server_type - server type
# -d use previously created dump
# -p prevent password reset for admin
# -v verbose mode (print all logs)
#

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh


DEST_DIR="./.dump"
DB_PATH=$(pwd)/.meteor/local/db
DB_WAIT_TIME=10

LOCAL_DB_PORT=3000
LOCAL_DB_HOST=127.0.0.1
LOCAL_DB_NAME=meteor

OUTPUT_STREAM=/dev/null
DROP_FLAG="--drop"

#parse script arguments
while [[ "$#" -gt 1 ]]; do
  key="$1"

  case ${key} in
    --no-drop)
    DROP_FLAG=""
    echo "No drop flag: YES ${DROP_FLAG}"
    ;;
    --no-hook)
    echo "Don't execute post dump script: YES"
    PREVENT_POST_HOOK="YES"
    ;;
    -d|--dump)
    echo "Use dump: YES"
    USE_DUMP="YES"
    ;;
    -v|--verbose)
    OUTPUT_STREAM="/dev/stdout"
    ;;
    *)
    echo "Unknown option ${1}"      # unknown option
    exit 1
    ;;
  esac

  shift # past argument or value
done

echo "Dumping database of '${SERVER_DESCRIPTION}'..."


if [[ "${USE_DUMP}" != "YES" ]]; then
  # refresh dump
  rm -rf "${DEST_DIR}/${MONGO_DB}"
  echo "Making remote database dump. Please, wait..."
  mongodump -u "${MONGO_USER}" -h "${MONGO_HOST}" -d "${MONGO_DB}" -p "${MONGO_PASSWORD}" -o "${DEST_DIR}" &> ${OUTPUT_STREAM}
fi

# remove old database instead of `meteor reset`
rm -rf .meteor/local/db
mkdir -p .meteor/local/db ${DEST_DIR}

echo "Starting local database ..."
mongod --dbpath="${DB_PATH}" --port="${LOCAL_DB_PORT}" --storageEngine=mmapv1 --nojournal > ${OUTPUT_STREAM} & sleep ${DB_WAIT_TIME}

mongorestore --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} --db=${LOCAL_DB_NAME} ${DROP_FLAG} "${DEST_DIR}/${MONGO_DB}" &> ${OUTPUT_STREAM}

if [[ ${PREVENT_POST_HOOK} != "YES" ]]; then
  POST_DUMP_HOOK_SCRIPT=${CONFIG_PATH}/post-dump.js

  if [[ -f ${POST_DUMP_HOOK_SCRIPT} ]]; then
    echo "Executing post dump hook script ..."
    mongo  --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} --eval "$(cat ${POST_DUMP_HOOK_SCRIPT})" > ${OUTPUT_STREAM}
  fi
fi

kill $! #kill db server

echo
echo "Congratulaitons! Your database is copied."