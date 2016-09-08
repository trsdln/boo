#!/usr/bin/env bash

#
# This script enables restoring of database from local project
# directory to remote server
#

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh

#== local settings
APP_LOCAL_PATH=$(pwd)
FROM_HOST="localhost:27017"
FROM_DB_NAME="meteor"
DUMP_DIR="./.dump"

DROP_FLAG='--drop'


#parse script arguments
while [[ "$#" -gt 1 ]]; do
  key="$1"

  case $key in
    --no-drop)
    echo "Prevent drop of remote database: ON"
    DROP_FLAG=""
    ;;
    *)
      echo "Unknown option ${1}"      # unknown option
      exit 1
    ;;
  esac

  shift # past argument or value
done

# first get confirmation... just in case :)
echo "#############################################################"
echo "# Restore you local database to [${MONGO_HOST}] ${SERVER_DESCRIPTION}?"
echo "# Answer: yes/no"
echo "#############################################################"

read CONFIRM

if [[ ${CONFIRM} =~ ^yes$ ]]; then
  echo "Starting local database server... "
  mongod --dbpath "${APP_LOCAL_PATH}/.meteor/local/db" > /dev/null & sleep 20

  #make dump
  echo "Making local database dump..."
  mongodump -h "${FROM_HOST}" -d "${FROM_DB_NAME}" -o "${DUMP_DIR}" > /dev/null

  echo "Restoring database from dump..."
  mongorestore --quiet ${DROP_FLAG} --db "${MONGO_DB}" -h "${MONGO_HOST}" -u "${MONGO_USER}" \
               -p "${MONGO_PASSWORD}" "${DUMP_DIR}/${FROM_DB_NAME}" > /dev/null

  kill $!
  echo
  echo "Done! Local database restored to [${MONGO_HOST}] ${SERVER_DESCRIPTION}."
fi