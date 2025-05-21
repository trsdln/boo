#!/usr/bin/env bash

require_app_root_dir

function mongo-copy_help {
  cat << EOF
Copy remote database

boo mongo-copy server_name
EOF
}

function mongo-copy {
  local server_name=$1
  source_deploy_conf ${server_name}

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      *)
        echo_error "Unknown option ${key}"
        exit 1
        ;;
    esac

    shift # past argument or value
  done

  printf "Selected database of '${COLOR_SUCCESS}${SERVER_DESCRIPTION}${COLOR_DEFAULT}'\n"

  local initial_dump_folder="${BOO_DB_DUMP_DIR}/$(get_db_name_by_mongo_url ${MONGO_URL})"
  local dump_folder="${BOO_DB_DUMP_DIR}/${server_name}"

  # refresh dump
  rm -rf "${dump_folder}"
  echo "Making remote database dump. Please, wait..."

  mongodump \
    ${CUSTOM_MONGODUMP_FLAGS} \
    --uri "${MONGO_URL}" \
    --out "${BOO_DB_DUMP_DIR}"
  local copy_res=$?

  if [ "$copy_res" == "0" ]; then
    mv "${initial_dump_folder}" "${dump_folder}"
    echo_success "'${server_name}' database is successfully copied!"
  else
    echo_error "Failed to copy '${server_name}' DB!"
    exit $copy_res
  fi
}
