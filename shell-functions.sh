#!/usr/bin/env bash

pull-all(){
    for subDir in `ls -d */`; do
        if [[ -d ${subDir}/.git ]]; then
            tput bold; tput setaf 2; echo "\033[4m$subDir\033[0m"
            (cd ${subDir} && git pull --rebase)
        fi
    done
}
