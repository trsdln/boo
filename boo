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

# ensure we are at Meteor's project root
if [ ! -d ../config ] || [ ! -d .meteor ]; then
  CUR_DIR=$(pwd)
  echo "Error: '${CUR_DIR}' is not a project's root directory or '../config' folder is missing!"
  exit 1
fi

SCRIPT_FILE=${SCRIPT_SOURCE_DIR}/lib/${SCRIPT_NAME}.sh

if [[ -f ${SCRIPT_FILE} ]]; then
  ${SCRIPT_FILE} ${SCRIPT_SOURCE_DIR} ${SCRIPT_ARGS}
else
  # source custom actions
  ACTIONS_CONF=../config/boo-actions.conf
  if [[ -f ${ACTIONS_CONF} ]]; then
    . ${ACTIONS_CONF}
  fi

  ALIAS_TYPE=$(type -t ${SCRIPT_ALIAS})
  if [[ ${ALIAS_TYPE} == 'function' ]]; then
    "${SCRIPT_ALIAS}" ${SCRIPT_ARGS}
  else
    echo "Unknown action: '${SCRIPT_ALIAS}'"
    exit 1
  fi
fi
