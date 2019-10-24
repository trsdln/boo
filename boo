#!/usr/bin/env bash

function get_boo_root_path {
  local boo_script_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local boo_root_path

  if [ -f "${boo_script_location}/common.sh" ]; then
    # not npm package - used locally
    boo_root_path=${boo_script_location}
  else
    # installed as npm package
    local npm_root="$(which npm &> /dev/null && npm config get prefix)/lib/node_modules/boo"
    local yarn_root="$(which yarn &> /dev/null && yarn global dir)/node_modules/boo"

    if [ -d "${npm_root}" ]; then
      boo_root_path="${npm_root}"
    else
      boo_root_path="${yarn_root}"
    fi
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

  if [[ "$(type -t ${action_name})" == 'function' ]]; then
    ${action_name} ${action_args} # execute action
  else
    echo_error "Unknown action: '${action_name}'"
    exit 1
  fi
}


BOO_ROOT_PATH=$(get_boo_root_path)

# source common functions
. ${BOO_ROOT_PATH}/common.sh

# source configuration if available
source_boorc

# split action name and action arguments
ACTION_NAME=$1
ALL_ARGS="$@"
execute_action ${BOO_ROOT_PATH} ${ACTION_NAME} "${ALL_ARGS#* }"
