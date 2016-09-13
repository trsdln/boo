#!/usr/bin/env bash

function deploy_help {
  cat << EOF
Deploys application to specified server

boo deploy server_name
EOF
}

function deploy_to_heroku {
  echo "Server type: Heroku"
  local server_name=$1
  local branch_name=`git rev-parse --abbrev-ref HEAD`

  # upsert Heroku remote
  if git remote -v | grep "${server_name}" > /dev/null; then
    git remote set-url ${server_name} ${HEROKU_REMOTE}
  else
    git remote add ${server_name} ${HEROKU_REMOTE}
  fi

  # set root url
  heroku config:add ROOT_URL="${ROOT_URL}" -r ${server_name}

  # set Mongo url
  heroku config:add MONGO_URL="${MONGO_URL}" -r ${server_name}

  # set Meteor settings
  heroku config:add METEOR_SETTINGS="$(cat ../config/${server_name}/settings.json)" -r ${server_name}

  git push -f ${server_name} ${branch_name}:master
}


function deploy_to_aws {
  echo "Server type: AWS"
  local server_name=$1

  cd ../config/${server_name}

  # prevent building of mobile platforms
  local platforms_file=../../app/.meteor/platforms
  local platforms_file_backup=${platforms_file}.bak

  # backup platforms config
  mv ${platforms_file} ${platforms_file_backup}

  cat > "${platforms_file}" <<- EOM
browser
server

EOM

  # deploy app
  mupx deploy

  # get old platforms config back
  rm -f ${platforms_file}
  mv ${platforms_file_backup} ${platforms_file}
}


function deploy_to_galaxy {
  local server_name=$1
  echo "Server type: Galaxy"
  # todo: add build in env variables to settings.json support
  export DEPLOY_HOSTNAME
  meteor deploy ${DOMAIN_NAME} --owner ${OWNER_ID} --settings ../config/${server_name}/settings.json
}


function verify_deployment {
  echo "Verifying deployment...";
  sleep ${VERIFY_TIMEOUT}
  curl -o /dev/null -s ${ROOT_URL} && echo "OK" || echo "FAILED"
}


function deploy {
  local server_name=$1
  source_deploy_conf ${server_name}

  echo " - ${SERVER_DESCRIPTION} [${ROOT_URL}]"

  case ${SERVER_TYPE} in
    heroku)
      deploy_to_heroku ${server_name}
      verify_deployment
    ;;
    aws)
      deploy_to_aws ${server_name}
    ;;
    galaxy)
      deploy_to_galaxy ${server_name}
      verify_deployment
    ;;
    *)
      echo "Unknown server type: ${SERVER_TYPE}"
      exit 1
    ;;
  esac

  echo "Deployment finished";
}
