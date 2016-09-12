#!/usr/bin/env bash

function get_boo_root_path {
  local boo_script_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local boo_root_path

  if [[ ${boo_script_location} == '/usr/local/bin' ]]; then
    # installed as npm package
    boo_root_path="$(npm config get prefix)/lib/node_modules/boo"
  else
    # used locally
    boo_root_path=${boo_script_location}
  fi

  echo ${boo_root_path}
}


function source_action {
  local boo_root=$1
  local action_name=$2

  local action_file=${boo_root}/lib/${action_name}.sh

  if [[ -f ${action_file} ]]; then
    . ${action_file}
  else
    # source user's custom actions
    source_config_file 'boo-actions.conf' 'silent'
  fi
}


function execute_action {
  local boo_root=$1
  local action_name=$2
  local action_args=$3

  source_action ${boo_root} ${action_name}

  [[ -z ${NO_METEOR_ROOT+x} ]] && ensure_meteor_root_dir

  if [[ "$(type -t ${action_name})" == 'function' ]]; then
    ${action_name} ${action_args} # execute action
  else
    echo "Unknown action: '${action_name}'"
    exit 1
  fi
}


BOO_ROOT_PATH=$(get_boo_root_path)

# source common functions
. ${BOO_ROOT_PATH}/common.sh

# split action name and action arguments
ACTION_NAME=$1
ALL_ARGS="$@"
execute_action ${BOO_ROOT_PATH} ${ACTION_NAME} "${ALL_ARGS#* }"
