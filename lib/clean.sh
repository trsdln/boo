#!/usr/bin/env bash

function clean {
  echo "Cleaning up Meteor build at '.meteor/local'"
  rm -rf .meteor/local/.build* .meteor/local/build .meteor/local/bundler-cache .meteor/local/cordova-build
  echo "Cleaning finished!"
}
