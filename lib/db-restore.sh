#!/usr/bin/env bash


FROM_HOST="localhost:27017"
FROM_DB_NAME="meteor"
DUMP_ROOT_DIR="./.dump"

function print_restore_status {
  local drop_flag=$1
  local drop_enabled=$([[ ${drop_flag} == "" ]] && echo "NO" || echo "YES")
  cat << EOF

######################################
# WARNING!!!                         #
# You may lost data at remote server #
######################################

Server: ${SERVER_DESCRIPTION}
URL: ${ROOT_URL}
Mongo: ${MONGO_HOST}
Drop enabled: ${drop_enabled}

Are you sure? (Enter 'yes' to continue)
EOF
}

function db-restore_help {
  cat << EOF
This script enables restoring of database from local project directory to remote server

boo db-restore server_name [--no-drop|-D] [-v|--verbose]

Options:
--no-drop|-D  - prevent all collections drop before dump restore
-v|--verbose  - verbose mode (print all logs)
EOF
}

function db-restore {
  local server_name=$1
  source_deploy_conf ${server_name}

  local app_local_db_path="$(pwd)/.meteor/local/db"
  local drop_flag='--drop'
  local output_stream=/dev/null

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      --no-drop|-D)
      drop_flag=''
      ;;
      -v|--verbose)
      output_stream=/dev/stdout
      ;;
      *)
      echo "Unknown option: ${key}"
      exit 1
      ;;
    esac

    shift # past argument or value
  done

  # first get confirmation... just in case :)
  print_restore_status ${drop_flag}
  read CONFIRM

  if [[ ${CONFIRM} =~ ^yes$ ]]; then
    echo "Starting local database server... "
    mongod --dbpath "${app_local_db_path}" > ${output_stream} &

    local mongod_pid=$!
    sleep 20

    echo "Making local database dump..."
    mongodump -h "${FROM_HOST}" -d "${FROM_DB_NAME}" -o "${DUMP_ROOT_DIR}" &> ${output_stream}

    kill ${mongod_pid}

    echo "Restoring database from dump..."

    # --quiet
    # &> ${output_stream}
    mongorestore ${drop_flag} --db "${MONGO_DB}" -h "${MONGO_HOST}" -u "${MONGO_USER}" \
      -p "${MONGO_PASSWORD}" "${DUMP_ROOT_DIR}/${FROM_DB_NAME}"

    echo "Done! Local database restored to ${SERVER_DESCRIPTION} [${MONGO_HOST}]."
  fi
}
