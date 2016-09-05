#!/usr/bin/env bash

if [[ $2 != '' ]]; then
  SERVER_TYPE=$2
else
  SERVER_TYPE='development'
fi

CONFIG_PATH=../config/${SERVER_TYPE}

SETTINGS_PATH=${CONFIG_PATH}/settings.json

if [ "${ROOT_URL}" != "http://localhost:3000" ]; then
   MOBILE_SERVER_ARG="--mobile-server ${ROOT_URL}"
else
   MOBILE_SERVER_ARG=""
fi


case "$1" in
  "android")
    echo "Staring Android (emulator) app on ${ROOT_URL}"
    meteor run android --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  "android-device")
    echo "Staring Android (device) app on ${ROOT_URL}"
    meteor run android-device --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  "ios")
    echo "Staring iOS (emulator) app on ${ROOT_URL}"
    meteor run ios --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  "ios-device")
    echo "Staring iOS (device) app on ${ROOT_URL}"
    meteor run ios-device --settings ${SETTINGS_PATH} ${MOBILE_SERVER_ARG}
    ;;
  "debug")
    echo "Starting browser app in debug mode"
    meteor debug --settings ${SETTINGS_PATH}
    ;;
  *)
    echo "Starting browser app on ${LOCALHOST_URL}"
    meteor run --settings ${SETTINGS_PATH}
    ;;
esac
