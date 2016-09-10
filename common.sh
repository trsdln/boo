#!/usr/bin/env bash

# error handling
function on_error {
  local parent_line_number="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_line_number}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_line_number}; exiting with status ${code}"
  fi
  echo ""

  exit "${code}"
}
trap 'on_error ${LINENO}' ERR


function source_config_file {
  local config_file=../config/$1
  local silent=$2

  if [ -f ${config_file} ]; then
    [[ ${silent} != 'silent' ]] && echo "Using configuration ${config_file}"
    . ${config_file} # source config file
  else
    if [[ ${silent} != 'silent' ]]; then
      echo "Error: Configuration '${config_file}' not found!"
      exit 1
    fi
  fi
}


function source_deploy_conf {
  if [ -z ${1+x} ]; then
     echo "Server isn't specified!"
     exit 1
  fi

  local server_name=$1
  local config_file=${server_name}/deploy.conf
  source_config_file ${config_file}
}


function ensure_meteor_root_dir {
  # ensure we are at Meteor's project root
  if [ ! -d ../config ] || [ ! -d .meteor ]; then
    echo "Error: '$(pwd)' is not a project's root directory or '../config' folder is missing!"
    exit 1
  fi
}

function prepend_with_boo_root {
  local local_path=$1
  echo "${BOO_ROOT_PATH}/${local_path}"
}