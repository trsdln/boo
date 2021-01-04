#!/usr/bin/env bash

function db-copy_help {
  cat << EOF
Combines both sql-copy and mongo-copy commands.

boo db-copy server_name [flags]

Note: combines flags from both commands.
EOF
}

function db-copy {
  # store at separate variable to prevent
  # arguments' "spreading"
  local all_args="$@"

  # run sql first to prevent initialization
  # of POSTGRES_INSTANCE variable
  execute_action "${BOO_ROOT_PATH}" "sql-copy" "$all_args"
  execute_action "${BOO_ROOT_PATH}" "mongo-copy" "$all_args"
}
