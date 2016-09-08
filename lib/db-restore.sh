#!/usr/bin/env bash

#
# This script enables restoring of database from local project
# directory to remote server
#

# source common part
. ${1}/common.sh

# local settings
APP_LOCAL_PATH=$(pwd)
FROM_HOST="localhost:27017"
FROM_DB_NAME="meteor"

DUMP_DIR="./.dump"
DROP_FLAG='--drop'

function printWarningMessage() {
  local drop_enabled=$([[ ${DROP_FLAG} == "" ]] && echo "NO" || echo "YES")
  echo ""
  echo "######################################"
  echo "# WARNING!!!                         #"
  echo "# You may lost data at remote server #"
  echo "######################################"
  echo ""
  echo "Server: ${SERVER_DESCRIPTION}"
  echo "URL: ${ROOT_URL}"
  echo "Mongo: ${MONGO_HOST}"
  echo "Drop enabled: ${drop_enabled}"
  echo ""
  echo "Are you sure? (Enter 'yes' to continue)"
}

#parse script arguments
while [[ "$#" -gt 2 ]]; do
  key="$1"

  case $key in
    --no-drop)
    DROP_FLAG=""
    ;;
    *)
    echo "Unknown option: ${1}"
    exit 1
    ;;
  esac

  shift # past argument or value
done

# first get confirmation... just in case :)
printWarningMessage
read CONFIRM

if [[ ${CONFIRM} =~ ^yes$ ]]; then
  echo "Starting local database server... "
  mongod --dbpath "${APP_LOCAL_PATH}/.meteor/local/db" > /dev/null &
  MONGOD_PID=$!
  sleep 20

  #make dump
  echo "Making local database dump..."
  mongodump -h "${FROM_HOST}" -d "${FROM_DB_NAME}" -o "${DUMP_DIR}" > /dev/null

  echo "Restoring database from dump..."
  mongorestore --quiet ${DROP_FLAG} --db "${MONGO_DB}" -h "${MONGO_HOST}" -u "${MONGO_USER}" \
               -p "${MONGO_PASSWORD}" "${DUMP_DIR}/${FROM_DB_NAME}" > /dev/null

  kill ${MONGOD_PID}
  echo ""
  echo "Done! Local database restored to ${SERVER_DESCRIPTION} [${MONGO_HOST}]."
fi
