#!/usr/bin/env bash

NO_METEOR_ROOT=1

# prints help for specified action
function help {
  local action_name=$1

  source_action ${BOO_ROOT_PATH} ${action_name}

  local action_help_name="${action_name}_help"
  if [[ "$(type -t ${action_help_name})" == 'function' ]]; then
    ${action_help_name} # show action help
  else
    echo "Action '${action_name}' doesn't have help info."
    exit 1
  fi
}