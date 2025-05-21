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

  source_deploy_conf ${2}
  if is_sql_configured; then
    execute_action "${BOO_ROOT_PATH}" "sql-restore" "$all_args"
  fi
  execute_action "${BOO_ROOT_PATH}" "mongo-restore" "$all_args"
}
