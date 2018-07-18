#!/usr/bin/env bash

require_app_root_dir 
require_meteor_root_dir 

function lines-of-code {
   cat \
   <(git ls-files) \
   <(git submodule foreach 'git ls-files | sed "s|^|$path/|"') \
   | grep -E '^(imports|client|server|packages|lib).+\.js' \
   | xargs wc -l \
   | tail -n 1
}
