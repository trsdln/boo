#!/usr/bin/env bash

require_app_root_dir 
require_meteor_root_dir 

function run_help {
  cat << EOF
Starts Meteor app with specified set of settings

boo run server_name [run_mode=local] [-p port=3000]

run_mode  - mode application should run in. Possible values:
android|android-device|ios|ios-device|debug|local

-p|--port - specify the port you want to run Meteor application
EOF
}


function _parse_key_parameters {
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
        -p|--port)
          PORT="$2"
          shift # past argument
          ;;
        *)
          # unknown option
        ;;
    esac
      shift # past argument or value
  done
}

function run {
  local server_name=$1
  source_deploy_conf ${server_name}

  local run_mode=$2
  local settings_path="${BOO_CONFIG_ROOT}/${server_name}/settings.json"

  PORT="3000"

  _parse_key_parameters $@

  if [ -z ${ROOT_URL+x} ]; then
     MOBILE_SERVER_ARG=""
     ROOT_URL="http://localhost:${PORT}/"
  else
     MOBILE_SERVER_ARG="--mobile-server ${ROOT_URL}"
  fi

  case ${run_mode} in
    android)
      echo_success "Staring Android (emulator) app on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run android --settings ${settings_path} ${MOBILE_SERVER_ARG} --port ${PORT}
      ;;
    android-device)
      echo_success "Staring Android (device) app on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run android-device --settings ${settings_path} ${MOBILE_SERVER_ARG} --port ${PORT}
      ;;
    ios)
      echo_success "Opening iOS app in Xcode on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run ios-device --settings ${settings_path} ${MOBILE_SERVER_ARG} --port ${PORT}
      ;;
    debug)
      echo_success "Starting browser app in debug mode"
      meteor debug --settings ${settings_path} --debug-port ${PORT}
      ;;
    local|*)
      echo_success "Starting browser app locally"
      meteor run --settings ${settings_path} --port ${PORT}
      ;;
  esac
}
