#!/usr/bin/env bash

function version {
  echo $(cat ${BOO_ROOT_PATH}/package.json | grep 'version')
}
