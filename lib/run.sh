#!/usr/bin/env bash

function run_help {
  cat << EOF
Starts Meteor app with specified set of settings

boo run server_name [run_mode=local]

run_mode  - mode application should run in. Possible values:
android|android-device|ios|ios-device|debug|local
EOF
}

function run {
  local server_name=$1
  source_deploy_conf ${server_name}

  local run_mode=$2
  local settings_path="../config/${server_name}/settings.json"

  if [ -z ${ROOT_URL+x} ]; then
     MOBILE_SERVER_ARG=""
     ROOT_URL="http://localhost:3000/"
  else
     MOBILE_SERVER_ARG="--mobile-server ${ROOT_URL}"
  fi

  case ${run_mode} in
    android)
      echo_success "Staring Android (emulator) app on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run android --settings ${settings_path} ${MOBILE_SERVER_ARG}
      ;;
    android-device)
      echo_success "Staring Android (device) app on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run android-device --settings ${settings_path} ${MOBILE_SERVER_ARG}
      ;;
    ios)
      echo_success "Opening iOS app in Xcode on ${TEXT_UNDERLINE}${ROOT_URL}"
      meteor run ios --settings ${settings_path} ${MOBILE_SERVER_ARG}
      ;;
    debug)
      echo_success "Starting browser app in debug mode"
      meteor debug --settings ${settings_path}
      ;;
    local|*)
      echo_success "Starting browser app locally"
      meteor run --settings ${settings_path}
      ;;
  esac
}
