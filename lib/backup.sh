#!/usr/bin/env bash

require_app_root_dir 

function backup_help {
  cat << EOF
Backups already cached database dump from '.dump' directory

boo backup
EOF
}


function backup {
  local server_name=$1
  source_deploy_conf ${server_name}

  # additional configuration
  source_config_file 'backup.conf'

  local db_name=$(get_db_name_by_mongo_url ${MONGO_URL})

  local dump_folder="./.dump/${db_name}"

  local date_str=`date +%Y-%m-%d`
  local backup_file_name="${db_name}-${date_str}.zip"

  echo "Making backup ${backup_file_name}..."
  zip -r ${backup_file_name}  ${dump_folder}

  mkdir -p ${OUT_FOLDER}
  mv ${backup_file_name}  ${OUT_FOLDER}/.

  echo_success "Saved as ${OUT_FOLDER}/${backup_file_name}"
}
