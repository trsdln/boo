#!/usr/bin/env bash

function mongo_help {
  cat << EOF
Open MongoDB shell to remote server

boo mongo server_name
EOF
}

function mongo {
  local server_name=$1
  source_deploy_conf ${server_name}

  echo "Connecting to database of ${server_name}..."

  local first_replica_set_host=${MONGO_HOST%,*}

  # "which" prevents self invocation
  $(which mongo) ${MONGO_CUSTOM_FLAGS} ${first_replica_set_host}/${MONGO_DB} -u ${MONGO_USER} -p ${MONGO_PASSWORD}
}
