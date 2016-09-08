#!/bin/bash

#
# Arguments:
# server_type - server type
# -d use previously created dump
# -p prevent password reset for admin
# -v verbose mode (print all logs)
#

# source common part
. ${1}/common.sh


DUMP_ROOT_FOLDER="./.dump"
DB_PATH=$(pwd)/.meteor/local/db
DB_WAIT_TIME=10

LOCAL_DB_PORT=3000
LOCAL_DB_HOST=127.0.0.1
LOCAL_DB_NAME=meteor

OUTPUT_STREAM=/dev/null
DROP_FLAG="--drop"

#parse script arguments
while [[ "$#" -gt 2 ]]; do
  key="$1"

  case ${key} in
    --no-drop)
    DROP_FLAG=""
    echo "Prevent database drop: YES"
    ;;
    --no-hook)
    PREVENT_POST_HOOK="YES"
    echo "Prevent post dump hook: YES"
    ;;
    -d|--dump)
    USE_DUMP="YES"
    echo "Use local dump: YES"
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

echo "Selected database of '${SERVER_DESCRIPTION}'"

# remove old database instead of `meteor reset`
echo "Removing local database..."
rm -rf .meteor/local/db
mkdir -p .meteor/local/db ${DUMP_ROOT_FOLDER}

if [[ "${USE_DUMP}" != "YES" ]]; then
  # refresh dump
  rm -rf "${DUMP_ROOT_FOLDER}/${MONGO_DB}"
  echo "Making remote database dump. Please, wait..."
  mongodump -u "${MONGO_USER}" -h "${MONGO_HOST}" -d "${MONGO_DB}" -p "${MONGO_PASSWORD}" -o "${DUMP_ROOT_FOLDER}" &> ${OUTPUT_STREAM}
fi

DUMP_FOLDER="${DUMP_ROOT_FOLDER}/${MONGO_DB}"

# check if dump exists
if [[ ! -d ${DUMP_FOLDER} ]]; then
  echo "Dump '${DUMP_FOLDER}' doesn't exists!"
  exit 1
fi

echo "Starting local database ..."
mongod --dbpath="${DB_PATH}" --port="${LOCAL_DB_PORT}" --storageEngine=mmapv1 --nojournal > ${OUTPUT_STREAM} &
MONGOD_PID=$!
sleep ${DB_WAIT_TIME}

mongorestore --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} --db=${LOCAL_DB_NAME} ${DROP_FLAG} "${DUMP_FOLDER}" &> ${OUTPUT_STREAM}

if [[ ${PREVENT_POST_HOOK} != "YES" ]]; then
  POST_DUMP_HOOK_SCRIPT=${CONFIG_PATH}/post-dump.js

  if [[ -f ${POST_DUMP_HOOK_SCRIPT} ]]; then
    echo "Executing post dump hook script ..."
    mongo  --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} --eval "$(cat ${POST_DUMP_HOOK_SCRIPT})" > ${OUTPUT_STREAM}
  fi
fi

kill ${MONGOD_PID}

echo
echo "The database is successfully copied"
