#!/usr/bin/env bash

require_app_root_dir 

function backup_help {
  cat << EOF
Backups already cached database dump from $BOO_DB_DUMP_DIR directory

boo backup server_name
EOF
}


function backup {
  local server_name=$1
  source_deploy_conf ${server_name}

  if [ -f "$(resolve_config_file_path 'backup.conf')" ]; then
    # additional configuration
    source_config_file 'backup.conf'
  fi

  cd ${BOO_DB_DUMP_DIR}
  local mongo_dump_dir="${server_name}"

  local sql_dump_file="sql/${server_name}.sql"
  if [ ! -f "${sql_dump_file}" ]; then 
    sql_dump_file=""
  fi

  local date_str=`date '+%Y-%m-%d'`
  local backup_file_name="${server_name}-${date_str}.zip"

  echo "Making backup ${backup_file_name}..."
  zip -r ${backup_file_name} ${mongo_dump_dir} ${sql_dump_file}

  if [ ! -z ${BACKUP_OUTPUT_PATH+x} ]; then
    mkdir -p ${BACKUP_OUTPUT_PATH}
    mv ${backup_file_name}  ${BACKUP_OUTPUT_PATH}/.
  fi

  echo_success "Saved as ${BACKUP_OUTPUT_PATH:-$BOO_DB_DUMP_DIR}/${backup_file_name}"
}
