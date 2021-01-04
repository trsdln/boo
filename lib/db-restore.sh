#!/usr/bin/env bash

function db-restore_help {
  cat << EOF
Combines both sql-restore and mongo-restore commands.

boo db-restore server_name_from server_name_to [flags]

Note: combines flags from both commands.
EOF
}

function db-restore {
  # store at separate variable to prevent
  # arguments' "spreading"
  local all_args="$@"

  # run sql first to prevent initialization
  # of POSTGRES_INSTANCE variable
  execute_action "${BOO_ROOT_PATH}" "sql-restore" "$all_args"
  execute_action "${BOO_ROOT_PATH}" "mongo-restore" "$all_args"
}
