#!/usr/bin/env bash

require_app_root_dir 
require_meteor_root_dir 

function clean_help {
  cat << EOF
Removes everything from '.meteor/local' except 'db' folder

boo clean
EOF
}

function clean {
  echo "Cleaning up Meteor build at '.meteor/local'"
  rm -rf .meteor/local/.build* .meteor/local/build .meteor/local/bundler-cache .meteor/local/cordova-build
  echo_success "Cleaning finished!"
}
