#!/usr/bin/env bash

require_app_root_dir 

function app_help {
    cat << EOF
Execute boo action for other app

boo app_name action_name other_args...
EOF
}

function app {
  local app_name=${1}
  local app_dir="../../${app_name}/app"
  if [ -d ${app_dir} ]; then
    cd ${app_dir}
    local all_args="$@"
    printf "Executing action for '${COLOR_SUCCESS}${app_name}${COLOR_DEFAULT}' app\n"
    boo ${all_args#* }
  else
    echo_error "Application '${app_name}' doesn't exist!";
    exit 1;
  fi
}
