#!/usr/bin/env bash

# provides SERVER_TYPE
# sources deploy.conf

# error handling
error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
    echo ""

  exit "${code}"
}
trap 'error ${LINENO}' ERR


if [ -z ${2+x} ]; then
   echo "You should specify server using first argument"
   exit 1
fi

SERVER_NAME=$2
CONFIG_PATH=../config/${SERVER_NAME}

# source config
CONFIG_FILE=${CONFIG_PATH}/deploy.conf

if [ -e ${CONFIG_FILE} ]; then
  echo "Using configuration for ${SERVER_NAME}"
  . ${CONFIG_FILE} # source config file
else
  echo "Error: Server configuration '${CONFIG_FILE}' not found!"
  exit 1
fi
