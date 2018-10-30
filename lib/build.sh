#!/usr/bin/env bash

require_app_root_dir 
require_meteor_root_dir 

BUILD_FOLDER="../build"
OUTPUT_STREAM=/dev/null

# common functions

function print_build_summary {
  cat << EOF

Building summary
mobile server: ${ROOT_URL}
mobile app version: $(extract_mobile_config_value 'version')
force-ssl is enabled: $(grep -q "force-ssl" ./.meteor/packages && echo 'YES' || echo 'NO')

Press ANY key to continue

EOF
}

function build_help {
  cat << EOF
Builds Meteor app for production

boo build server_name [-v|--verbose] [-c|--cleanup]

Options:
-v|--verbose  - enable verbose mode (print all logs)
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
  local mobile_app_id=$(extract_mobile_config_value 'id')

  cd "${BUILD_FOLDER}/android"

  # provide APK file if it is missed
  if [ ! -f ${unsigned_apk_name} ]; then
    cp ${alternative_apk_path} ./${unsigned_apk_name}
    echo_warning "Missing unsigned APK, so it was taken from ${alternative_apk_path}"
  fi

  # remove old signed APK
  if [ -f ${signed_apk_name} ]; then
    rm -f ${signed_apk_name}
  fi

  # sign APK
  jarsigner -keystore ../${BOO_CONFIG_ROOT}/keystore.jks \
     -storepass "${KEYSTORE_PASSWORD}" -keypass "${PRIVATE_KEY_PASSWORD}" \
     -verbose -sigalg SHA1withRSA -digestalg SHA1 \
     ${unsigned_apk_name} ${APP_NAME} > ${OUTPUT_STREAM}

  if [ -z "${ANDROID_HOME}" ]; then
    echo_danger "Error: Cannot find Android SDK - \$ANDROID_HOME is not defined!"
  fi

  ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/zipalign 4 \
     ${unsigned_apk_name} ${signed_apk_name} > ${OUTPUT_STREAM}

  mkdir -p ${APK_OUTPUT_FOLDER}
  rm -f ${APK_OUTPUT_FOLDER}/${signed_apk_name}
  cp ${signed_apk_name} ${APK_OUTPUT_FOLDER}

  echo_success "APK was saved to ${APK_OUTPUT_FOLDER} (PWD: $(pwd))"

  echo "Install APK on device (CTRL+C=Cancel)?"
  beep # signal that confirmations required
  read -rsn1

  echo "Remove old APK..."
  adb uninstall ${mobile_app_id}

  echo "Install new version..."
  adb install "${APK_OUTPUT_FOLDER}/${signed_apk_name}"
}

function sync_missing_assets {
  local sync_from=$1
  local sync_to=$2

  if [[ -d "${sync_from}" ]]; then
    echo_success "Syncing assets from '${sync_from}'"
    rsync -a -v "${sync_from}/." "${sync_to}/."
  fi
}

function post_build_ios {
  local mobile_app_name=$(extract_mobile_config_value 'name')
  local ios_project_path="${BUILD_FOLDER}/ios/project"

  if [[ -d "${ios_project_path}" ]]; then
    local ios_project_files="${ios_project_path}/${mobile_app_name}"
    sync_missing_assets ./resources/ios-missing-icons "${ios_project_files}/Images.xcassets/AppIcon.appiconset"
    sync_missing_assets ./resources/ios-missing-splash "${ios_project_files}/Images.xcassets/LaunchImage.launchimage"

    # open generated project inside Xcode
    echo_success "Opening app at Xcode"
    open -a Xcode "${ios_project_path}/${mobile_app_name}.xcworkspace"
  fi
}

function build {
  local server_name=$1
  source_deploy_conf ${server_name}

  # additional configuration
  source_config_file 'build.conf'

  local build_verbose_flag=""

  # parse rest of function arguments
  while [[ $(($#-1)) -gt 0 ]]; do
    local key="$2"

    case ${key} in
      -v|--verbose)
      OUTPUT_STREAM=/dev/stdout
      build_verbose_flag="--verbose"
      ;;
      *)
      echo_error "Unknown option ${key}"
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

  # build project for production
  meteor build ${BUILD_FOLDER} ${build_verbose_flag} \
         --mobile-settings=${BOO_CONFIG_ROOT}/${server_name}/settings.json --server ${ROOT_URL}

  # iOS
  post_build_ios

  # Android
  post_build_android

  echo_success "Done!"
}
