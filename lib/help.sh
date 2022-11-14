#!/usr/bin/env bash

function help_help {
  cat << EOF
boo help

Prints help for specified action

boo help action_name

Build-in actions:
deploy
run
backup
build
clean
db-copy
db-restore
sql-copy
sql-restore
sql
mongo-copy
mongo-restore
mongosh
help
version
EOF
}


function help {
  local action_name=$1

  source_action ${BOO_ROOT_PATH} ${action_name}

  local action_help_name="${action_name}_help"
  if [ "$(type -t ${action_help_name})" = 'function' ]; then
    ${action_help_name} # show action help
  elif [ "${action_name}" = "" ]; then
    help_help
  else
    echo_warning "Action '${action_name}' doesn't have help info."
    exit 1
  fi
}
