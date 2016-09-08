#!/usr/bin/env bash

#
# Builds app
#

#
# To generate new key
# $ keytool -genkey -alias "HospoHero" -keyalg RSA -keysize 2048 -validity 10000
#
# Note: keystore backup is required. APK uploaded to
# Google Play should be always signed with the same key, stored in `~/.keysore`.
#


SCRIPT_SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# source common part
. ${SCRIPT_SOURCE_DIR}/common.sh

# apply additional configuration
# provides APP_NAME, APK_OUTPUT_FOLDER, ANDROID_HOME, ANDROID_BUILD_TOOLS_VERSION,
# KEYSTORE_PASSWORD, PRIVATE_KEY_NAME, PRIVATE_KEY_PASSWORD
. ${CONFIG_PATH}/../build.conf


# common functions
function beep() {
  echo -ne '\007'
}

function extractConfigValue() {
  local valueKey=$1
  local value=$(cat mobile-config.js | grep "${valueKey}:" | tail -n 1)
  value=${value#*\'}
  value=${value%\'*}
  echo ${value}
}

# basic build settings
BUILD_FOLDER="../build"
UNSIGNED_APK_NAME="release-unsigned.apk"
ALTERNATIVE_APK_PATH="./project/build/outputs/apk/android-armv7-release-unsigned.apk"

# extract some mobile config settings
MOBILE_APP_VERSION=$(extractConfigValue 'version')
MOBILE_APP_ID=$(extractConfigValue 'id')
MOBILE_APP_NAME=$(extractConfigValue 'name')

SIGNED_APK_NAME="${APP_NAME}_${MOBILE_APP_VERSION}.apk"

OUTPUT_STREAM=/dev/null

#parse script arguments
while [[ "$#" -gt 1 ]]; do
  key="$1"

  case $key in
    -v|--verbose)
    OUTPUT_STREAM="/dev/stdout"
    BUILD_VERBOSE_FLAG="--verbose"
    ;;
    -c|--clean)
    CLEANUP="YES"
    ;;
    -h|--help)
    echo 'Meteor App Build Script'
    echo ''
    echo 'Options:'
    echo '-v|--verbose enable verbose mode (print all logs)'
    echo '-c|--cleanup cleanup .meteor/local directory'
    echo '-h|--help show this message'
    echo ''
    exit 0
    ;;
    *)
    echo "Unknown option ${1}"
    exit 1
    ;;
  esac

  shift # past argument or value
done



if grep -Fxq "force-ssl" ./.meteor/packages; then
  IS_FORCE_SSL_ENABLED='YES'
else
  IS_FORCE_SSL_ENABLED='NO'
fi

echo "==== Building summary ===="
echo "* mobile server: ${ROOT_URL}"
echo "* mobile app version: ${MOBILE_APP_VERSION}"
echo "* force-ssl is enabled: ${IS_FORCE_SSL_ENABLED}"
echo "=========================="
echo
echo "Press ANY key to continue"
read -rsn1

echo "Remove old build in ${BUILD_FOLDER}"
rm -rf ${BUILD_FOLDER}

if [[ ${CLEANUP} == 'YES' ]]; then
  # we cannot cleanup .meter/local each time because of https://github.com/meteor/meteor/issues/6756
  echo "Remove folders in ./.meteor/local"
  rm -rf .meter/local/.build* .meter/local/build .meter/local/bundler-cache .meter/local/cordova-build
#else
#  # Fixes Meteor#6756 based on:
#  # https://github.com/meteor/meteor/issues/6756#issuecomment-243409677
#  ANDROID_BUILD_PATH="${BUILD_FOLDER}/android/project"
#  mkdir -p ${ANDROID_BUILD_PATH}
#  cp -a .meteor/local/cordova-build/platforms/android/build "${ANDROID_BUILD_PATH}"
fi

# build project for production
meteor build ${BUILD_FOLDER} ${BUILD_VERBOSE_FLAG} --mobile-settings=${CONFIG_PATH}/settings.json --server ${ROOT_URL}


# ==== iOS

#open generated project inside Xcode
open -a Xcode "${BUILD_FOLDER}/ios/project/${MOBILE_APP_NAME}.xcodeproj"


# ==== Android

# sign APK
cd "${BUILD_FOLDER}/android"

# provide APK file if it is missed
if [ ! -f ${UNSIGNED_APK_NAME} ]; then
  cp ${ALTERNATIVE_APK_PATH} ./${UNSIGNED_APK_NAME}
  echo "Missing unsigned APK, so it was taken from ${ALTERNATIVE_APK_PATH}"
fi

# remove old signed APK
if [ -f ${SIGNED_APK_NAME} ]; then
  rm -f ${SIGNED_APK_NAME}
fi

beep
jarsigner -keystore ../../config/keystore.jks -storepass "${KEYSTORE_PASSWORD}" -keypass "${PRIVATE_KEY_PASSWORD}" -verbose -sigalg SHA1withRSA -digestalg SHA1 \
   ${UNSIGNED_APK_NAME} ${APP_NAME} > ${OUTPUT_STREAM}

${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}/zipalign 4 ${UNSIGNED_APK_NAME} ${SIGNED_APK_NAME} > ${OUTPUT_STREAM}

# save to shared folder on Dropbox
rm -f ${APK_OUTPUT_FOLDER}/${SIGNED_APK_NAME}
cp ${SIGNED_APK_NAME} ${APK_OUTPUT_FOLDER}

echo "APKs saved to ${APK_OUTPUT_FOLDER}"

echo "Install APK on device (CTRL+C=Cancel)?"
beep # signal that confirmations required
read -rsn1

echo "Remove old APK:"
adb uninstall ${MOBILE_APP_ID}

echo "Install new version:"
adb install "${APK_OUTPUT_FOLDER}/${SIGNED_APK_NAME}"

echo "DONE"