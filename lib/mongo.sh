#!/usr/bin/env bash

require_app_root_dir

function mongo_help {
  cat << EOF
Open MongoDB shell to remote server

boo mongo server_name
EOF
}

function mongo {
  local server_name=$1
  local mongo_command_args="${@:2}"

  source_deploy_conf ${server_name}

  # if running script ask for confirmation
  if [ ! -z "${2+x}" ] && [ -f "${2}" ]; then
    confirm_production_operation "${server_name}" "${2}"
  fi

  echo "Connecting to database of ${server_name}..."

  # "which" prevents self invocation
  $(which mongo) "${MONGO_URL}" ${mongo_command_args}
}
