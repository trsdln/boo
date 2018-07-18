#!/usr/bin/env bash

require_app_root_dir 
require_meteor_root_dir 

function mongo-dev_help {
    cat << EOF
Start mongodb with db path .meteor/local/db and connect via mongo

boo mongo-dev
EOF
}

function mongo-dev {
  local app_name=$(cd .. && basename $(pwd))
  printf "Starting development database for '${COLOR_SUCCESS}${app_name}${COLOR_DEFAULT}'...\n"
  mongod --dbpath=.meteor/local/db > /dev/null &
  local mongod_pid=$!
  sleep 5
  mongo meteor
  kill $!
}