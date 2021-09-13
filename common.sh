#!/usr/bin/env bash

COLOR_SUCCESS='\e[34m'
COLOR_WARNING='\e[33m'
COLOR_ERROR='\e[31m'
COLOR_DEFAULT='\E(B\E[m'
TEXT_BOLD='\e[1m'
TEXT_UNDERLINE='\e[4m'

function echo_success {
  printf "${COLOR_SUCCESS}${1}${COLOR_DEFAULT}\n"
}

function echo_warning {
  printf "${COLOR_WARNING}${1}${COLOR_DEFAULT}\n"
}

function echo_error {
  printf "${COLOR_ERROR}${1}${COLOR_DEFAULT}\n"
}

function test_echo_colors {
  echo_success "success"
  echo_warning "warning"
  echo_error "error"
}

# error handling
function on_error {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo_error "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo_error "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi

  exit "${code}"
}
trap 'on_error ${LINENO}' ERR


function source_config_file {
  local config_file=${BOO_CONFIG_ROOT}/$1

  if [ ! -f "${config_file}" ]; then
    # try to find custom server root path sourced from .boorc
    local server_name="${1%%/*}"
    if [ "$server_name" != "${1}" ]; then
      local server_root_env_name="boo_${server_name}_config_root"
      local alt_config_file="${!server_root_env_name}/${1#*/}"
      if [ -f "${alt_config_file}" ]; then
        local config_file="${alt_config_file}"
      fi
    fi
  fi

  local silent=$2

  if [ -f ${config_file} ]; then
    [[ ${silent} != 'silent' ]] && echo "Using configuration ${config_file}"
    . ${config_file} # source config file
  else
    if [[ ${silent} != 'silent' ]]; then
      echo_error "Error: Configuration '${config_file}' not found!"
      exit 1
    fi
  fi
}


function source_deploy_conf {
  if [ -z ${1+x} ]; then
     echo_error "Server isn't specified!"
     exit 1
  fi

  local server_name=$1
  local config_file=${server_name}/deploy.conf
  source_config_file ${config_file}
}

function require_meteor_root_dir {
  # ensure we are at Meteor's root dir
  if [ ! -d .meteor ]; then
    echo_error "Error: '$(pwd)' is not a Meteor's project root directory ('.meteor' is missing)!"
    exit 1
  fi
}

function require_app_root_dir {
  # ensure we are at project's root dir
  if [ ! -d "${BOO_CONFIG_ROOT}" ]; then
    echo_error "Error: '$(pwd)' is not a project's root directory or '${BOO_CONFIG_ROOT}' folder is missing!"
    exit 1
  fi
}

function source_boorc {
  local boo_rc_file="./.boorc"
  if [[ -f "${boo_rc_file}" ]]; then
    . ${boo_rc_file}
  else
    BOO_LOCAL_DB_PATH=".meteor/local/db"
    BOO_CONFIG_ROOT="../config"
  fi
}

function get_db_name_by_mongo_url {
  local url=$1
  # naive implementation (doesn't handle ?arg=val cases)
  echo "${url##*/}"
}

confirm_production_operation() {
  local target_env=$1
  local description=$2
  if [ "${target_env}" = "production" ]; then
    echo_error "    You're trying to perform ${description} at **production**. Are you sure? (yes/NO)"
    read CONFIRM

    if [ "${CONFIRM}" != "yes" ]; then
      echo_error "Operation aborted!"
      exit 1
    fi
  fi
}
