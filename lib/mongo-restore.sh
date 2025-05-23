#!/usr/bin/env bash

require_app_root_dir

function print_restore_status {
  local drop_flag=$1
  local drop_enabled=$([[ ${drop_flag} == "" ]] && echo "NO" || echo "YES")
  local _db_restore_status_msg

  read -r -d '' _db_restore_status_msg << EOF
${COLOR_ERROR}${TEXT_BOLD}
######################################
# WARNING!!!                         #
# You may lost data at remote server #
######################################
${COLOR_DEFAULT}
Server: ${SERVER_FROM_DESCRIPTION} -> ${SERVER_DESCRIPTION}

Drop enabled: ${TEXT_BOLD}${COLOR_ERROR}${drop_enabled}${COLOR_DEFAULT}

Are you sure? (Enter 'yes' to continue):
EOF

  printf "${_db_restore_status_msg} "
}

function mongo-restore_help {
  cat << EOF
This script enables restoring of database from local project directory to remote server

boo mongo-restore server_name_from server_name_to [--no-drop|-D] [--yes-im-sure|-Y]

Options:
-D|--no-drop     - prevent all collections drop before dump restore
-Y|--yes-im-sure - prevent confirmation
EOF
}

function mongo-restore {
  local server_name_from=$1
  local server_name_to=$2

  local drop_flag='--drop'
  local skip_confirmation="no"

  shift # skip server_name_to

  # parse script arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      --no-drop|-D)
        drop_flag=''
        ;;
      -Y|--yes-im-sure)
        skip_confirmation="yes"
        ;;
      *)
        echo_warning "Unknown option: ${key}"
        ;;
    esac

    shift # past argument or value
  done

  # collect configs data

  source_deploy_conf ${server_name_from}
  unset MONGO_URL # just in case
  SERVER_FROM_DESCRIPTION=${SERVER_DESCRIPTION}

  source_deploy_conf ${server_name_to}

  # confirmation
  if [ "${skip_confirmation}" != "yes" ]; then
    # first get confirmation... just in case :)
    print_restore_status ${drop_flag}

    read CONFIRM

    if [ "${CONFIRM}" != "yes" ]; then
      echo_error "Operation aborted!"
      exit 1
    fi
  fi

  # double confirmation for production
  confirm_production_operation "${server_name_to}" "restore DB"

  if [ "${drop_flag}" != '' ]; then
    echo_warning "Dropping old DB..."
    # otherwise old DB's collections will be kept if new dump doesn't contain those
    mongosh --quiet --eval="db.getCollectionNames().filter(coll => coll !== 'system.views').forEach(coll => db.getCollection(coll).drop())" \
      "${MONGO_URL}" || exit 1
  fi

  echo "Restoring database from dump..."

  mongorestore "${drop_flag}" \
    --uri "${MONGO_URL}" \
    --nsExclude 'admin.system.*' \
    --noIndexRestore "${BOO_DB_DUMP_DIR}/${server_name_from}"
  local restore_res=$?

  if [ "$restore_res" = 0 ]; then
    local post_dump_hook
    post_dump_hook=$(resolve_config_file_path "${server_name_from}/post-dump.js")

    if [ "$?" = 0 ]; then
      echo_warning "Executing post dump hook..."
      cd $(dirname $post_dump_hook)
      mongosh --quiet "${MONGO_URL}" "$(basename ${post_dump_hook})" || exit 1
    fi

    echo_success "'${server_name_from}' database successfully restored to '${SERVER_DESCRIPTION}'!"
  else
    echo_error "Failed to restore DB!"
    exit $restore_res
  fi
}
