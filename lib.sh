#!/usr/bin/env bash

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
