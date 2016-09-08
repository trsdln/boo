#!/usr/bin/env bash


SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh


SETTINGS_PATH=${CONFIG_PATH}/settings.json

if [ -z ${ROOT_URL+x} ]; then
   MOBILE_SERVER_ARG=""
   ROOT_URL="http://localhost:3000/"
else
   MOBILE_SERVER_ARG="--mobile-server ${ROOT_URL}"
fi

case "$2" in
  android)
    echo "Staring Android (emulator) app on ${ROOT_URL}"
    meteor run android --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  android-device)
    echo "Staring Android (device) app on ${ROOT_URL}"
    meteor run android-device --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  ios)
    echo "Staring iOS (emulator) app on ${ROOT_URL}"
    meteor run ios --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  ios-device)
    echo "Staring iOS (device) app on ${ROOT_URL}"
    meteor run ios-device --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  debug)
    echo "Starting browser app in debug mode"
    meteor debug --settings ${SETTINGS_PATH}
    ;;
  local|*)
    echo "Starting browser app locally"
    meteor run --settings ${SETTINGS_PATH}
    ;;
esac
