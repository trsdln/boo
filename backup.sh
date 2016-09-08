#!/usr/bin/env bash

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh

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
