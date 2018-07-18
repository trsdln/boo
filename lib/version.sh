#!/usr/bin/env bash

function extract_package_json_value {
  local valueKey=$1
  local value=$(cat ${BOO_ROOT_PATH}/package.json | grep "\"${valueKey}\":" | tail -n 1)
  value=${value#*\: \"}
  value=${value%\"*}
  echo ${value}
}

function version {
  echo_success "$(extract_package_json_value 'name')"
  echo "$(extract_package_json_value 'description')"
  echo "Version: $(extract_package_json_value 'version')"
}
