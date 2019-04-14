#!/usr/bin/env bash

init-lconf(){
    if [[ -f ".config.json" ]]
    then
        echo ".config.jso is already present. Do you want to reinitialize (Y/N)? "
        read ANSWER

        if [[ ! (${ANSWER} = "Y" || ${ANSWER} = "y") ]]; then
            return 0;
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
    if [[ $? = 0 ]]
    then
        cat > .config.json <<EOF
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

pull-all(){
    for subDir in `ls -d */`; do
        if [[ -d ${subDir}/.git ]]; then
            tput bold; tput setaf 2; echo "\033[4m$subDir\033[0m"
            (cd ${subDir} && git pull --rebase)
        fi
    done
}

__config-local-git(){
    # set up git user details and sign key
    local CONFIG_FILE_NAME=$1

    local GIT_USERNAME=$(jq -r .git_username ${CONFIG_FILE_NAME})
    local COMMITTER_NAME=$(jq -r .committer_name ${CONFIG_FILE_NAME})
    local EMAIL=$(jq -r .email ${CONFIG_FILE_NAME})
    local SIGNKEY=$(jq -r .signkey ${CONFIG_FILE_NAME})
    local IDENTITY_FILE=$(jq -r .identity_file_path ${CONFIG_FILE_NAME})

    git config user.name ${COMMITTER_NAME}
    git config user.email ${EMAIL}
    git config user.signingkey ${SIGNKEY}
    git config core.sshCommand "ssh -i ${IDENTITY_FILE}"
}

lc-init(){
    local CONFIG_FILE_NAME=../.config.json
    if [[ ! -f ${CONFIG_FILE_NAME} ]]; then
        echo "Config file is not found!. Please create it. For more info check https://github.com/sumanmaity112/dev-tools#lc-init"
        return 1;
    fi

    git init .

    __config-local-git ${CONFIG_FILE_NAME}
}

lc-clone(){
    local CONFIG_FILE_NAME=./.config.json
    if [[ ! -f ${CONFIG_FILE_NAME} ]]; then
        echo "Config file is not found!. Please create it. For more info check https://github.com/sumanmaity112/dev-tools#lc-clone"
        return 1;
    fi

    local URL=$1
    local REPO_NAME=$(basename "$URL" ".${URL##*.}")

    local TARGET_DIR=${2:-${REPO_NAME}}

    ssh-add $(jq -r .identity_file_path ${CONFIG_FILE_NAME})
    git clone ${URL} ${TARGET_DIR}

    if [[ $? = 0 ]]
    then
        pushd ${TARGET_DIR} > /dev/null
            __config-local-git ${CONFIG_FILE_NAME}
        popd > /dev/null
    else
        return $?
    fi
}

start-vpn(){
    local VPN_NAME=$1;

    if [[ -z ${VPN_NAME} ]]; then
        echo "Please provide VPN name. For more info check https://github.com/sumanmaity112/dev-tools#start-vpn"
        return 1;
    fi

    osascript -e "tell application \"Tunnelblick\"" -e "connect \"${VPN_NAME}\"" -e "end tell"
}

stop-vpn(){
    local VPN_NAME=$1;

    if [[ -z ${VPN_NAME} ]]; then
        echo "Please provide VPN name. For more info check https://github.com/sumanmaity112/dev-tools#stop-vpn"
        return 1;
    fi

    osascript -e "tell application \"Tunnelblick\"" -e "disconnect \"${VPN_NAME}\"" -e "end tell"
}

__download-talisman(){
    local TALISMAN_PATH=$1

    curl https://thoughtworks.github.io/talisman/install.sh > ${TALISMAN_PATH}
    chmod +x ${TALISMAN_PATH}
}

__add-talisman-hook(){
    local TALISMAN_PATH=$1
    local DESTINATION_PATH=${2:-"."}

   if [[ -d ${DESTINATION_PATH} ]]; then

       (cd ${DESTINATION_PATH} && sh ${TALISMAN_PATH} > /dev/null && mv .git/hooks/pre-push .git/hooks/pre-commit)

       if [[ $? = 0 ]]; then
           tput bold; tput setaf 2; echo "Talisman successfully installed to '${DESTINATION_PATH}/.git/hooks/pre-commit'."
       fi
    fi
}

install-talisman(){
    local DESTINATION_PATH=$1
    local TALISMAN_PATH=/tmp/install-talisman.sh

    __download-talisman ${TALISMAN_PATH}

    __add-talisman-hook ${TALISMAN_PATH} ${DESTINATION_PATH}
}

install-talisman-all(){
    local TALISMAN_PATH=/tmp/install-talisman.sh

    __download-talisman ${TALISMAN_PATH}

    local SUB_DIRS=$(ls -d */ 2> /dev/null)
    local RET_CODE=$?

    if [[ ! ${RET_CODE} -eq 0 ]]; then
       echo "No sub directories presents in the current path"
       return ${RET_CODE};
    fi

    for SUB_DIR in ${SUB_DIRS}; do
        if [[ -d ${SUB_DIR}/.git ]]; then
            __add-talisman-hook ${TALISMAN_PATH} ${SUB_DIR}
        fi
    done
}
