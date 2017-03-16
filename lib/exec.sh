#!/usr/bin/env bash

function exec-help {
  echo "Executes custom command"
}

function exec {
  local command_str=$@
  ${command_str} # execute command
}
