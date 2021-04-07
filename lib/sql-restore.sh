#!/usr/bin/env bash

require_app_root_dir

function sql-restore_help {
  cat << EOF
Restore PostgreSQL database local copy to specified instance.
Note: For development use only. Doesn't handle big databases

boo sql-copy server_name_from server_name_to [--yes-im-sure|-Y]

Options:
-Y|--yes-im-sure - prevent confirmation
EOF
}

function print_restore_warning {
  local _db_restore_status_msg

  read -r -d '' _db_restore_status_msg << EOF
${COLOR_ERROR}${TEXT_BOLD}
######################################
# WARNING!!!                         #
# You may lost data at remote server #
######################################
${COLOR_DEFAULT}
Server: local ${server_name_from} -> ${server_name_to}

Are you sure? (Enter 'yes' to continue):
EOF

  printf "${_db_restore_status_msg} "
}

function sql-restore {
  server_name_from=$1
  server_name_to=$2

  shift # skip server_name_to

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      -Y|--yes-im-sure)
        skip_confirmation="yes"
        ;;
      *)
        echo_warning "Unknown option: ${key}"
        ;;
    esac

    shift # past argument or value
  done

  source_deploy_conf ${server_name_to}

  if [ "${skip_confirmation}" != "yes" ]; then
    # first get confirmation... just in case :)
    print_restore_warning

    read CONFIRM

    if [ "${CONFIRM}" != "yes" ]; then
      echo_error "Operation aborted!"
      exit 1
    fi
  fi

  # double confirmation for production
  if [ "${server_name_to}" = "production" ]; then
    echo_error "    You're trying to restore to **production**. Are you sure? "
    read CONFIRM

    if [ "${CONFIRM}" != "yes" ]; then
      echo_error "Operation aborted!"
      exit 1
    fi
  fi

  . ${BOO_ROOT_PATH}/sql.sh

  local dump_file="${dump_dir}/${server_name_from}.sql"

  if [ ! -f "${dump_file}" ]; then
    echo_error "Error: file ${dump_file} not found"
    exit 1
  fi

  start_sql_proxy

  # drop existing database
  local default_postgres_url="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PROXY_PORT}/postgres"
  echo "drop database ${POSTGRES_DB}; create database ${POSTGRES_DB};" \
    | psql --no-psqlrc -v ON_ERROR_STOP=1 "${default_postgres_url}"

  local psql_drop_res=$?
  if [ "$psql_drop_res" != "0" ]; then
    echo_error "Error: Failed to drop old DB. See logs above for details."
    exit "$psql_drop_res"
  fi

  echo "Restoring dump..."
  psql --no-psqlrc "${POSTGRE_PROXY_URL}" < "${dump_file}"

  exit_res="$?"

  stop_sql_proxy

  if [ "$exit_res" = "0" ]; then
    echo_success "Done!"
  else
    echo_error "Failed!"
    exit "$exit_res"
  fi
}
