#!/usr/bin/env bash

echo "Cleaning up .meteor/local"
rm -rf .meteor/local/.build* .meteor/local/build .meteor/local/bundler-cache .meteor/local/cordova-build
