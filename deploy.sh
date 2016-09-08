#!/usr/bin/env bash

#
# Main deployment script
#

SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh


echo " - ${SERVER_DESCRIPTION}"

function deployToHeroku {
  echo "Server type: Heroku"
  BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`

  # upsert Heroku remote
  if git remote -v | grep "${SERVER_NAME}" > /dev/null; then
    git remote set-url ${SERVER_NAME} ${HEROKU_REMOTE}
  else
    git remote add ${SERVER_NAME} ${HEROKU_REMOTE}
  fi

  # set root url
  heroku config:add ROOT_URL="${ROOT_URL}" -r ${SERVER_NAME}

  # set Mongo url
  heroku config:add MONGO_URL="${MONGO_URL}" -r ${SERVER_NAME}

  # set Meteor settings
  heroku config:add METEOR_SETTINGS="$(cat ${CONFIG_PATH}/settings.json)" -r ${SERVER_NAME}

  git push -f ${SERVER_NAME} ${BRANCH_NAME}:master
}

function deployToAws {
  echo "Server type: AWS"

  cd ${CONFIG_PATH}

  # prevent building of mobile platforms
  PLATFORMS=../../app/.meteor/platforms
  PLATFORMS_BAK=${PLATFORMS}.bak

  # backup platforms config
  mv ${PLATFORMS} ${PLATFORMS_BAK}

  cat > "${PLATFORMS}" <<- EOM
browser
server

EOM

  # deploy app
  mupx deploy

  # get old platforms config back
  rm -f ${PLATFORMS}
  mv ${PLATFORMS_BAK} ${PLATFORMS}
}

function deployToGalaxy {
  echo "Server type: Galaxy"
  # todo: add build in env variables to settings.json support
  export DEPLOY_HOSTNAME
  meteor deploy ${DOMAIN_NAME} --owner ${OWNER_ID} --settings ${CONFIG_PATH}/settings.json
}

function verifyDeployment {
  echo "Verifying deployment...";
  sleep ${VERIFY_TIMEOUT}
  curl -o /dev/null -s ${ROOT_URL} && echo "OK" || echo "FAILED"
}

case ${SERVER_TYPE} in
  heroku)
    deployToHeroku
    verifyDeployment
  ;;
  aws)
    deployToAws
  ;;
  galaxy)
    deployToGalaxy
    verifyDeployment
  ;;
  *)
    echo "Unknown server type: ${SERVER_TYPE}"
    exit 1
  ;;
esac

echo "Deployment finished";