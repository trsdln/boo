#!/usr/bin/env bash

require_app_root_dir

function sql-copy_help {
  cat << EOF
Make PostgreSQL database copy using pg_dump
Note: For development use only. Doesn't handle big databases

boo sql-copy server_name
EOF
}

function sql-copy {
  local server_name=$1

  . ${BOO_ROOT_PATH}/sql.sh
  source_deploy_conf_for_sql "${server_name}"

  start_sql_proxy

  echo "Making DB copy..."
  local dump_file=$(sql_dump_file_path ${server_name})
  pg_dump "${POSTGRES_URL}" > "${dump_file}"
  exit_res="$?"

  stop_sql_proxy

  if [ "$exit_res" = "0" ]; then
    echo_success "Done!"
  else
    echo_error "Failed!"
    exit "$exit_res"
  fi
}
