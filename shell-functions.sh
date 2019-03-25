#!/usr/bin/env bash

pull-all(){
    for subDir in `ls -d */`; do
        if [[ -d ${subDir}/.git ]]; then
            tput bold; tput setaf 2; echo "\033[4m$subDir\033[0m"
            (cd ${subDir} && git pull --rebase)
        fi
    done
}

lc-clone(){
    CONFIG_FILE_NAME=./.config.json
    if [[ ! -f ${CONFIG_FILE_NAME} ]]; then
        echo "Config file is not found!. Please create it. For more info check https://github.com/sumanmaity112/dev-tools#lc-clone"
        return 1;
    fi

    GIT_USERNAME=$(jq -r .git_username ${CONFIG_FILE_NAME})
    COMMITTER_NAME=$(jq -r .committer_name ${CONFIG_FILE_NAME})
    EMAIL=$(jq -r .email ${CONFIG_FILE_NAME})
    SIGNKEY=$(jq -r .signkey ${CONFIG_FILE_NAME})

    URL=$1
    REPO_NAME=$(basename "$URL" ".${URL##*.}")

    TARGET_DIR=${2:-${REPO_NAME}}
    WITHOUT_GITURL=${URL:15}

    NEW_URL="git@github.com-$GIT_USERNAME:$WITHOUT_GITURL"

    git clone ${NEW_URL} ${TARGET_DIR}

    if [[ $? = 0 ]]
    then
        # set up git user details and sign key

        pushd ${TARGET_DIR} > /dev/null
            echo $(pwd)
            git config user.name ${COMMITTER_NAME}
            git config user.email ${EMAIL}
            git config user.signingkey ${SIGNKEY}

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
