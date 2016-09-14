#!/usr/bin/env bash

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
