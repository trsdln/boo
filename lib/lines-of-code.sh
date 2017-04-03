#!/usr/bin/env bash

function lines-of-code {
   cat \
   <(git ls-files) \
   <(git submodule foreach 'git ls-files | sed "s|^|$path/|"') \
   | grep -E '^(imports|client|server|packages|lib).+\.js' \
   | xargs wc -l \
   | tail -n 1
}
