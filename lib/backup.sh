#!/usr/bin/env bash

# source common part
. ${1}/common.sh

# addtional configuration
. ${CONFIG_PATH}/../backup.conf


DUMP_FOLDER="./.dump/${MONGO_DB}"

DATE_STR=`date +%Y-%m-%d`
BACKUP_FILE_NAME="${MONGO_DB}-${DATE_STR}.zip"

echo "Making backup ${BACKUP_FILE_NAME}..."
zip -r ${BACKUP_FILE_NAME}  ${DUMP_FOLDER}

mkdir -p ${OUT_FOLDER}
mv ${BACKUP_FILE_NAME}  ${OUT_FOLDER}/.

echo "Saved as ${OUT_FOLDER}/${BACKUP_FILE_NAME}"
