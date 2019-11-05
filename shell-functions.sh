#!/usr/bin/env bash

SCRIPT_DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"

LIBRARY_PATH="${SCRIPT_DIR}/lib.sh"
[[ -f ${LIBRARY_PATH} ]] && . ${LIBRARY_PATH}

init-lconf() {
  if [[ -f ".config.json" ]]; then
    echo ".config.jso is already present. Do you want to reinitialize (Y/N)? "
    read ANSWER

    if [[ ! (${ANSWER} == "Y" || ${ANSWER} == "y") ]]; then
      return 0
    fi
  fi

  echo "Starting initialization of local git config..."

  #read -p is not working for some reason

  echo "Enter git username: "
  read GIT_USERNAME
  echo "Enter git committer name: "
  read COMMITTER_NAME
  echo "Enter email id associated with given username: "
  read EMAIL
  echo "Enter GPG signkey: "
  read SIGNKEY
  echo "Enter identity file path: "
  read IDENTITY_FILE_PATH

  realpath ${IDENTITY_FILE_PATH:-""} 1>/dev/null
  if [[ $? == 0 ]]; then
    cat >.config.json <<EOF
{
  "git_username": "${GIT_USERNAME}",
  "committer_name": "${COMMITTER_NAME}",
  "email": "${EMAIL}",
  "signkey": "${SIGNKEY}",
  "identity_file_path": "$(realpath ${IDENTITY_FILE_PATH})"
}
EOF
    echo "Successfully initialized. Created $(realpath .config.json) file"
  else
    local OLD_RETURN=$?
    echo "Initialization failed"
    return ${OLD_RETURN}
  fi
}

pull-all() {
  for subDir in $(ls -d */); do
    if [[ -d ${subDir}/.git ]]; then
      tput bold
      tput setaf 2
      echo "\033[4m$subDir\033[0m"
      (cd ${subDir} && git pull --rebase)
    fi
  done
}

lc-init() {
  local CONFIG_FILE_NAME=$(realpath ../.config.json)
  if [[ ! -f ${CONFIG_FILE_NAME} ]]; then
    echo "Config file is not found!. Please create it. For more info check https://github.com/sumanmaity112/dev-tools#lc-init"
    return 1
  fi

  git init .

  __config-local-git ${CONFIG_FILE_NAME}
}

lc-clone() {
  local CONFIG_FILE_NAME=$(realpath ./.config.json)
  if [[ ! -f ${CONFIG_FILE_NAME} ]]; then
    echo "Config file is not found!. Please create it. For more info check https://github.com/sumanmaity112/dev-tools#lc-clone"
    return 1
  fi

  local URL=$1
  local REPO_NAME=$(basename "$URL" ".${URL##*.}")

  local TARGET_DIR=${2:-${REPO_NAME}}

  ssh-add $(jq -r .identity_file_path ${CONFIG_FILE_NAME})
  git clone ${URL} ${TARGET_DIR}

  if [[ $? == 0 ]]; then
    pushd ${TARGET_DIR} >/dev/null
    __config-local-git ${CONFIG_FILE_NAME}
    popd >/dev/null
  else
    return $?
  fi
}

start-vpn() {
  local VPN_NAME=$1

  if [[ -z ${VPN_NAME} ]]; then
    echo "Please provide VPN name. For more info check https://github.com/sumanmaity112/dev-tools#start-vpn"
    return 1
  fi

  osascript -e "tell application \"Tunnelblick\"" -e "connect \"${VPN_NAME}\"" -e "end tell"
}

stop-vpn() {
  local VPN_NAME=$1

  if [[ -z ${VPN_NAME} ]]; then
    echo "Please provide VPN name. For more info check https://github.com/sumanmaity112/dev-tools#stop-vpn"
    return 1
  fi

  osascript -e "tell application \"Tunnelblick\"" -e "disconnect \"${VPN_NAME}\"" -e "end tell"
}

install-talisman() {
  local DESTINATION_PATH=$1
  local TALISMAN_PATH=/tmp/install-talisman.sh

  __download-talisman ${TALISMAN_PATH}

  __add-talisman-hook ${TALISMAN_PATH} ${DESTINATION_PATH}
}

install-talisman-all() {
  local TALISMAN_PATH=/tmp/install-talisman.sh

  __download-talisman ${TALISMAN_PATH}

  local SUB_DIRS=$(ls -d */ 2>/dev/null)
  local RET_CODE=$?

  if [[ ! ${RET_CODE} -eq 0 ]]; then
    echo "No sub directories presents in the current path"
    return ${RET_CODE}
  fi

  for SUB_DIR in ${SUB_DIRS}; do
    if [[ -d ${SUB_DIR}/.git ]]; then
      __add-talisman-hook ${TALISMAN_PATH} ${SUB_DIR}
    fi
  done
}

upgrade() {
  upgrade_oh_my_zsh

  echo "Updating brew itself"
  brew update

  echo "Updating brew formulas"
  brew upgrade

  # shellcheck source=/dev/null
  source "${HOME}/.zshrc"
}

opsignin() {
  local accountname="${1:-my}"

  local curr_time
  curr_time="$(date +%s)"

  local session_file=${HOME}/.op/session
  local time_file=${HOME}/.op/last_time

  if [[ ! -e ${time_file} ]]; then
    echo export OP_LAST_TIME=1 >"${time_file}"
  fi

  # shellcheck source=/dev/null
  source "${time_file}"

  if [[ $((curr_time - OP_LAST_TIME)) -gt 1800 ]]; then
    if [[ -e ${session_file} ]]; then
      chmod 600 "${session_file}"
    fi

    if op signin "${accountname}" >"${session_file}"; then
      chmod 400 "${session_file}"
      echo export OP_LAST_TIME="${curr_time}" >"${time_file}"
    fi
  fi

  # shellcheck source=/dev/null
  source "${session_file}"
}

opsignout() {
  local accountname="${1:-my}"

  op signout
  unset OP_SESSION_"${accountname}"
}

op-get-note() {
  local note_name="${1}"
  if [[ -z "${note_name}" ]]; then
    echo "Please provide note name"
    exit 1
  fi

  op get item "${note_name}" | jq -rj '.details.notesPlain' | pbcopy
}
