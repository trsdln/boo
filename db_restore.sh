#!/usr/bin/env bash

#
# This script enables restoring of database from local project
# directory to remote server
#
# Options
# -s,--server (staging|testing|production) - server type
#

#== local settings
APP_LOCAL_PATH=$(pwd)
FROM_HOST="localhost:27017"
FROM_DB_NAME="meteor"
DUMP_DIR="./.dump"


#parse script arguments
while [[ "$#" -gt 0 ]]; do
  key="$1"

  case $key in
    -s|--server)
    SERVER_TYPE="$2"
    shift # past value argument
    ;;
    *)
      echo "Unknown option ${1}"      # unknown option
      exit 1
    ;;
  esac

  shift # past argument or value
done

if [ -z ${SERVER_TYPE+x} ]; then
   echo "You should specify server using '-s' parameter"
   exit 1
fi

# source config file with MONGO DB credentials
CONFIG_FOLDER=../config/${SERVER_TYPE}
. ${CONFIG_FOLDER}/deploy.conf


# first get confirmation... just in case :)
echo "#############################################################"
echo "# Restore you local database to [${MONGO_HOST}] ${SERVER_DESCRIPTION}?"
echo "# Are you sure admin password wasn't resetted?!"
echo "# Answer: yes/no"
echo "#############################################################"

read CONFIRM

if [[ ${CONFIRM} =~ ^yes$ ]]
then
  echo "Starting local database server... "
  mongod --dbpath "${APP_LOCAL_PATH}/.meteor/local/db" > /dev/null & sleep 20

  #make dump
  echo "Making local database dump..."
  mongodump -h "${FROM_HOST}" -d "${FROM_DB_NAME}" -o "${DUMP_DIR}" > /dev/null

  echo "Drop all collections on remote database before restore"
  mongo "${MONGO_HOST}/${MONGO_DB}" -u "${MONGO_USER}" -p "${MONGO_PASSWORD}" --eval "db.getCollectionNames().forEach(function (n) {if (n != 'system.indexes') {db[n].drop();}});"

  echo "Restoring database from dump..."
  mongorestore --db "${MONGO_DB}" -h "${MONGO_HOST}" -u "${MONGO_USER}" -p "${MONGO_PASSWORD}" --drop "${DUMP_DIR}/${FROM_DB_NAME}" > /dev/null

  kill $!
  echo
  echo "Done! Local database restored to [${MONGO_HOST}] ${SERVER_DESCRIPTION}."
fi