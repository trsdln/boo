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


function resolve_config_file_path {
  local config_file=${BOO_CONFIG_ROOT}/$1

  if [ -f "${config_file}" ]; then
    echo "${config_file}"
    return
  fi

  if [ ! -z ${BOO_ALTERNATIVE_CONFIG_ROOT+x} ]; then
    local alt_config_file=${BOO_ALTERNATIVE_CONFIG_ROOT}/$1
    if  [ -f "${alt_config_file}" ]; then
      echo "${alt_config_file}"
      return
    fi
  fi

  return 1
}


function source_config_file {
  local config_file
  config_file=$(resolve_config_file_path "${1}")
  local resolve_code=$?

  local silent=$2

  if [ "${resolve_code}" = 0 ]; then
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
     echo_error "Server isn't specified! Run 'boo help ${ACTION_NAME}' for details."
     exit 1
  fi

  local server_name=$1
  local config_file=${server_name}/boo.conf
  source_config_file ${config_file}
}

function require_app_root_dir {
  # ensure we are at project's root dir
  if [ ! -d "${BOO_CONFIG_ROOT}" ]; then
    echo_error "Error: '$(pwd)' is not a project's root directory or '${BOO_CONFIG_ROOT}' folder is missing!"
    exit 1
  fi
}

function source_boorc {
  BOO_DB_DUMP_DIR="./.dump"

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
  local url_suffix="${url##*/}"
  echo "${url_suffix%%\?*}"
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
