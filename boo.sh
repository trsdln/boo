#!/usr/bin/env bash

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_ALIAS=$1

ALL_ARGS="$@"
SCRIPT_ARGS="${ALL_ARGS#* }" # remove script alias from args

echo "ARGS: ${SCRIPT_ARGS}"

case ${SCRIPT_ALIAS} in
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