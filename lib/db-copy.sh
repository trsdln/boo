#!/bin/bash

require_app_root_dir

LOCAL_MONGO_URL="mongodb://localhost:27017/meteor"
DUMP_ROOT_FOLDER="./.dump"

function db-copy_help {
  cat << EOF
Copy remote database

boo db-copy server_name [-v|--verbose]

Options:
-v  - verbose mode (print all logs)
EOF
}

function db-copy {
  local server_name=$1
  source_deploy_conf ${server_name}

  local output_stream=/dev/null
  local drop_flag="--drop"
  local run_post_hook=1

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      -v|--verbose)
        output_stream="/dev/stdout"
        ;;
      *)
        echo_error "Unknown option ${key}"
        exit 1
        ;;
    esac

    shift # past argument or value
  done

  printf "Selected database of '${COLOR_SUCCESS}${SERVER_DESCRIPTION}${COLOR_DEFAULT}'\n"

  local dump_folder="${DUMP_ROOT_FOLDER}/$(get_db_name_by_mongo_url ${MONGO_URL})"

  # refresh dump
  rm -rf "${dump_folder}"
  echo "Making remote database dump. Please, wait..."

  # Force table scan fixes incompatibility problem between 4.x and 3.x
  # https://dba.stackexchange.com/a/226541
  mongodump \
    --forceTableScan \
    ${CUSTOM_MONGODUMP_FLAGS} \
    --uri "${MONGO_URL}" \
    --out "${DUMP_ROOT_FOLDER}" &> ${output_stream}

  if [ "$?" == "0" ]; then
    echo_success "'${server_name}' database is successfully copied!"
  else
    echo_error "Failed to copy '${server_name}' DB! Use -v flag to get more info."
  fi

}
