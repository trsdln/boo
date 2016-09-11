#!/bin/bash

DUMP_ROOT_FOLDER="./.dump"
DB_WAIT_TIME=10

LOCAL_DB_PORT=3000
LOCAL_DB_HOST=127.0.0.1
LOCAL_DB_NAME=meteor

function db-copy_help {
  cat << EOF
Copy remote database

boo db-copy server_type [-d|--dump] [-v|--verbose] [--no-drop|-D] [--no-hook|-H]

Options:
-d  - use previously created dump
-v  - verbose mode (print all logs)
--no-hook  - prevent post restore hook execution
--no-drop  - prevent database drop before restore
EOF
}


function db-copy {
  local server_name=$1
  source_deploy_conf ${server_name}

  local local_db_path=$(pwd)/.meteor/local/db

  local output_stream=/dev/null
  local drop_flag="--drop"
  local use_dump=0
  local run_post_hook=1

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      --no-drop|-D)
      drop_flag=""
      echo "Prevent database drop: YES"
      ;;
      --no-hook|-H)
      run_post_hook=0
      echo "Prevent post dump hook: YES"
      ;;
      -d|--dump)
      use_dump=1
      echo "Use local dump: YES"
      ;;
      -v|--verbose)
      output_stream="/dev/stdout"
      ;;
      *)
      echo "Unknown option ${key}"
      exit 1
      ;;
    esac

    shift # past argument or value
  done

  echo "Selected database of '${SERVER_DESCRIPTION}'"

  # remove old database instead of `meteor reset`
  echo "Removing local database..."
  rm -rf .meteor/local/db
  mkdir -p .meteor/local/db ${DUMP_ROOT_FOLDER}

  if [[ ${use_dump} != 1 ]]; then
    # refresh dump
    rm -rf "${DUMP_ROOT_FOLDER}/${MONGO_DB}"
    echo "Making remote database dump. Please, wait..."
    mongodump -u "${MONGO_USER}" -h "${MONGO_HOST}" -d "${MONGO_DB}" -p "${MONGO_PASSWORD}" \
      -o "${DUMP_ROOT_FOLDER}" &> ${output_stream}
  fi

  local dump_folder="${DUMP_ROOT_FOLDER}/${MONGO_DB}"

  # check if dump exists
  if [[ ! -d ${dump_folder} ]]; then
    echo "Dump '${dump_folder}' doesn't exists!"
    exit 1
  fi

  echo "Starting local database ..."
  mongod --dbpath="${local_db_path}" --port="${LOCAL_DB_PORT}" --storageEngine=mmapv1 \
    --nojournal > ${output_stream} &

  local mongod_pid=$!
  sleep ${DB_WAIT_TIME}

  mongorestore --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} --db=${LOCAL_DB_NAME} \
    ${drop_flag} "${dump_folder}" &> ${output_stream}

  if [[ ${run_post_hook} == 1 ]]; then
    local post_hook_file=../config/${server_name}/post-dump.js

    if [[ -f ${post_hook_file} ]]; then
      echo "Executing post dump hook script ..."
      mongo  --host=${LOCAL_DB_HOST} --port=${LOCAL_DB_PORT} \
        --eval "$(cat ${post_hook_file})" > ${output_stream}
    fi
  fi

  kill ${mongod_pid}

  echo "Database is successfully copied!"
}
