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

  source_deploy_conf ${server_name}

  . ${BOO_ROOT_PATH}/sql.sh

  start_sql_proxy

  echo "Making DB copy..."
  pg_dump "${POSTGRE_PROXY_URL}" > "${dump_dir}/${server_name}.sql"
  exit_res="$?"

  stop_sql_proxy

  if [ "$exit_res" = "0" ]; then
    echo_success "Done!"
  else
    echo_error "Failed!"
    exit "$exit_res"
  fi
}
