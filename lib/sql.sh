#!/usr/bin/env bash

require_app_root_dir

function sql_help {
  cat << EOF
Open psql shell to remote server

boo sql server_name
EOF
}

function sql {
  local server_name=$1
  local psql_command_args="${@:2}"

  source_deploy_conf ${server_name}

  . ${BOO_ROOT_PATH}/sql.sh

  start_sql_proxy

  echo "Connecting to proxy..."
  psql "${POSTGRES_URL}" ${psql_command_args}

  stop_sql_proxy
}
