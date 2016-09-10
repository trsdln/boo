#!/usr/bin/env bash

function backup {
  local server_name=$1
  source_deploy_conf ${server_name}

  # additional configuration
  source_config_file 'backup.conf'

  local dump_folder="./.dump/${MONGO_DB}"

  local date_str=`date +%Y-%m-%d`
  local backup_file_name="${MONGO_DB}-${date_str}.zip"

  echo "Making backup ${backup_file_name}..."
  zip -r ${backup_file_name}  ${dump_folder}

  mkdir -p ${OUT_FOLDER}
  mv ${backup_file_name}  ${OUT_FOLDER}/.

  echo "Saved as ${OUT_FOLDER}/${backup_file_name}"
}
