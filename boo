#!/usr/bin/env bash

BOO_SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ${BOO_SCRIPT_LOCATION} == '/usr/local/bin' ]]; then
  # installed as npm package
  # currently I have no idea how to get it dynamically
  SCRIPT_SOURCE_DIR='/usr/local/lib/node_modules/boo'
else
  # used locally
  SCRIPT_SOURCE_DIR=${BOO_SCRIPT_LOCATION}
fi


SCRIPT_ALIAS=$1

ALL_ARGS="$@"
SCRIPT_ARGS="${ALL_ARGS#* }" # remove script alias from args

case ${SCRIPT_ALIAS} in
  version)
  echo $(cat ${SCRIPT_SOURCE_DIR}/package.json | grep 'version')
  exit 0
  ;;
  *)
  SCRIPT_NAME=${SCRIPT_ALIAS}
  ;;
esac

SCRIPT_FILE=${SCRIPT_SOURCE_DIR}/${SCRIPT_NAME}.sh

if [[ -e ${SCRIPT_FILE} ]]; then
  ${SCRIPT_FILE} ${SCRIPT_ARGS}
else
  echo "Unknown command ${SCRIPT_ALIAS}"
  exit 1
fi
