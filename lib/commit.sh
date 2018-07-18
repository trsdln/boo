#!/usr/bin/env bash

function commit_help {
  cat << EOF
Small script that automatically adds [skip ci] to your commit messages

This command:
* adds all changed files to your commit
* commits changes with [skip ci] flag
* pushes changes to upstream remote branch

Useful for WIP commits if you have git hooks with tests/linting etc.

boo commit
EOF
}

function commit {
  git add --all
  echo "Added all files to commit"
 
  git status
 
  printf "Commit and push without hooks!\n\n"
 
  local commit_message=""
  printf "Please, enter your commit message below and press <Enter>\n"
  printf "> "
  read commit_message
 
  local flag_switch=""
  printf "Do you want to add [skip ci] to commit message:\n"
  printf "(N - for No) > "
  read flag_switch
  if [[ ${flag_switch} =~ ^N$ ]]; then
      echo "Skip CI flag DISABLED"
  else
      commit_message="${commit_message} [skip ci]"
  fi
 
  git commit -m "${commit_message}" --no-verify
 
  git push --no-verify
 
  echo_success "Committed and pushed: ${commit_message}"
}
