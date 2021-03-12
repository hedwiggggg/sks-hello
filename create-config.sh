#!/bin/bash

if [[ -z "${SKS_HELLO_USER_PASS}" ]]; then
  echo "SKS_HELLO_USER_PASS secret is missing. Abort."
  exit 1
else
  echo "Creating config file."

  cat << EOF > config
export IMG_NAME=sks-hello
export RELEASE=buster
export DEPLOY_ZIP=1
export LOCALE_DEFAULT=en_US.UTF-8
export TARGET_HOSTNAME=sks-hello
export KEYBOARD_KEYMAP=us
export KEYBOARD_LAYOUT="English (US)"
export TIMEZONE_DEFAULT=America/New_York
export FIRST_USER_NAME=sks
export FIRST_USER_PASS=${SKS_HELLO_USER_PASS}
export ENABLE_SSH=1
EOF

fi
