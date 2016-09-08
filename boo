#!/usr/bin/env bash

BOO_SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ${BOO_SCRIPT_LOCATION} == '/usr/local/bin' ]]; then
  # installed as npm package
  # currently I have no idea how to get it dynamically
  SCRIPT_SOURCE_DIR='/usr/local/lib/node_modules/boo'
else
  # used locally
  SCRIPT_SOURCE_DIR=${BOO_SCRIPT_LOCATION}
fi


SCRIPT_ALIAS=$1

ALL_ARGS="$@"
SCRIPT_ARGS="${ALL_ARGS#* }" # remove script alias from args

case ${SCRIPT_ALIAS} in
    run)
    ${SCRIPT_SOURCE_DIR}/run.sh ${SCRIPT_ARGS}
    ;;
    build)
    ${SCRIPT_SOURCE_DIR}/build.sh ${SCRIPT_ARGS}
    ;;
    deploy)
    ${SCRIPT_SOURCE_DIR}/to.sh ${SCRIPT_ARGS}
    ;;
    db-copy)
    ${SCRIPT_SOURCE_DIR}/db_copy.sh ${SCRIPT_ARGS}
    ;;
    db-restore)
    ${SCRIPT_SOURCE_DIR}/db_restore.sh ${SCRIPT_ARGS}
    ;;
    mongo)
    ${SCRIPT_SOURCE_DIR}/mongo.sh ${SCRIPT_ARGS}
    ;;
    clean)
    ${SCRIPT_SOURCE_DIR}/clean_build_cache.sh ${SCRIPT_ARGS}
    ;;
    *)
    echo "Unknown command ${SCRIPT_ALIAS}"
    exit 1
    ;;
esac
