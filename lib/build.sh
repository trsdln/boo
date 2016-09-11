#!/usr/bin/env bash


BUILD_FOLDER="../build"
OUTPUT_STREAM=/dev/null

# common functions

function print_build_summary {
  cat << EOF

Building summary
mobile server: ${ROOT_URL}
mobile app version: $(extract_mobile_config_value 'version')
force-ssl is enabled: $(grep -Fxq "force-ssl" ./.meteor/packages && echo 'YES' || echo 'NO')

Press ANY key to continue

EOF
}

function build_help {
  cat << EOF
Builds Meteor app for production

boo build server_name [-v|--verbose] [-c|--cleanup]

Options:
-v|--verbose  - enable verbose mode (print all logs)
-c|--cleanup  - cleanup .meteor/local directory
EOF
}

function beep {
  echo -ne '\007'
}

function extract_mobile_config_value {
  local valueKey=$1
  local value=$(cat mobile-config.js | grep "${valueKey}:" | tail -n 1)
  value=${value#*\'}
  value=${value%\'*}
  echo ${value}
}

function post_build_android {
  local unsigned_apk_name="release-unsigned.apk"
  local alternative_apk_path="./project/build/outputs/apk/android-armv7-release-unsigned.apk"
  
  local signed_apk_name="${APP_NAME}_$(extract_mobile_config_value 'version').apk"

  cd "${BUILD_FOLDER}/android"

  # provide APK file if it is missed
  if [ ! -f ${unsigned_apk_name} ]; then
    cp ${alternative_apk_path} ./${unsigned_apk_name}
    echo "Missing unsigned APK, so it was taken from ${alternative_apk_path}"
  fi

  # remove old signed APK
  if [ -f ${signed_apk_name} ]; then
    rm -f ${signed_apk_name}
  fi

  # sign APK
  jarsigner -keystore ../../config/keystore.jks \
     -storepass "${KEYSTORE_PASSWORD}" -keypass "${PRIVATE_KEY_PASSWORD}" \
     -verbose -sigalg SHA1withRSA -digestalg SHA1 \
     ${unsigned_apk_name} ${APP_NAME} > ${OUTPUT_STREAM}

  ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/zipalign 4 \
     ${unsigned_apk_name} ${signed_apk_name} > ${OUTPUT_STREAM}

  rm -f ${APK_OUTPUT_FOLDER}/${signed_apk_name}
  cp ${signed_apk_name} ${APK_OUTPUT_FOLDER}

  echo "APK was saved to ${APK_OUTPUT_FOLDER}"

  echo "Install APK on device (CTRL+C=Cancel)?"
  beep # signal that confirmations required
  read -rsn1

  echo "Remove old APK..."
  local mobile_app_id=$(extract_mobile_config_value 'id')
  adb uninstall ${mobile_app_id}

  echo "Install new version..."
  adb install "${APK_OUTPUT_FOLDER}/${signed_apk_name}"
}


function build {
  local server_name=$1
  source_deploy_conf ${server_name}

  # additional configuration
  source_config_file 'build.conf'

  local cleanup=""
  local build_verbose_flag=""

  # parse rest of function arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      -v|--verbose)
      OUTPUT_STREAM=/dev/stdout
      build_verbose_flag="--verbose"
      ;;
      -c|--clean)
      cleanup="YES"
      ;;
      *)
      echo "Unknown option ${key}"
      exit 1
      ;;
    esac

    shift # past argument or value
  done

  print_build_summary
  read -rsn1

  if [[ -d ${BUILD_FOLDER} ]]; then
    echo "Remove old build in ${BUILD_FOLDER}"
    rm -rf ${BUILD_FOLDER}
  fi

  # we cannot cleanup .meter/local each time because of https://github.com/meteor/meteor/issues/6756
  if [[ ${cleanup} == 'YES' ]]; then
    . $(prepend_with_boo_root 'lib/clean.sh')
    clean
  fi

  # build project for production
  meteor build ${BUILD_FOLDER} ${build_verbose_flag} \
         --mobile-settings=../config/${server_name}/settings.json --server ${ROOT_URL}

  # iOS
  # open generated project inside Xcode
  local mobile_app_name=$(extract_mobile_config_value 'name')
  open -a Xcode "${BUILD_FOLDER}/ios/project/${mobile_app_name}.xcodeproj"

  # Android
  post_build_android

  echo "Done!"
}
