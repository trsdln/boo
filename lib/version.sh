#!/usr/bin/env bash

NO_METEOR_ROOT=1

function version {
  echo $(cat ${BOO_ROOT_PATH}/package.json | grep 'version')
}
