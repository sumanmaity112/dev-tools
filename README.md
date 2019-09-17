# dev-tools

This repository holds some custom commands to make developer life easy. 


Table of Contents
=================
   * [dev-tools](#dev-tools)
      * [Setup](#setup)
      * [Commands](#commands)
         * [init-lconf](#init-lconf)
         * [pull-all](#pull-all)
         * [lc-init](#lc-init)
         * [lc-clone](#lc-clone)
         * [start-vpn](#start-vpn)
         * [stop-vpn](#stop-vpn)
         * [install-talisman](#install-talisman)
         * [install-talisman-all](#install-talisman-all)
         * [upgrade](#upgrade)
         * [jwtp](#jwtp)

## Setup
Add this to your `~/.profile` / `.bash_profile` / `~/.zshrc` (depending
on your shell and setup):
```bash
CUSTOM_COMMANDS=path/to/dev-tools/shell-functions.sh
[[ -f ${CUSTOM_COMMANDS} ]] && . ${CUSTOM_COMMANDS}
```

## Commands
### init-lconf
This command is used to initialize local config file (`./.config.json`). This file is used by `lc-init`, `lc-clone` etc commands. This file holds the information about **git username**, **committer name**, **identity file** and **signkey** for current directory. 
Check the following example config created by this command.

```json
{
    "git_username":"janedoe",
    "committer_name": "Jane Doe",
    "email": "janedoe123@mail.com",
    "signkey": "76232YRH8D",
    "identity_file_path": "/Users/jane/.ssh/id_github"
}
```
Here **git_username** defines the github username, **committer_name** defines the actual name for the user, **email** defines the E-mail id associate with the given github userId, **identity_file_path** defines the identity file will be use during **ssh** connection and **signkey** defines the gpg signkey. Check this link to know more about [how to create new GPG key](https://help.github.com/en/articles/generating-a-new-gpg-key).

Note: A new identity file can be created using the following command
 ```sh 
 ssh-keygen -t rsa -b 4096 -C "<email id>"
 ```

### pull-all
This command is use to pull latest code for all the git repositories present in the current directory from remote.

### lc-init
This command is use to create an empty Git repository or reinitialize an existing one in the current directory.
For this command to work properly you have to create `.config.json` in the working directory (where you want to clone repositories). You can create the config file manually or you can use [init-lconf](#init-lconf) command to do it.

#### syntax
```lc-init```

### lc-clone
This command is use to clone a git repository with *ssh url* and *custom ssh identity file*. This commands also configure *git username*, *committer name* and *signkey* only for the same repository.
For this command to work properly you have to create `.config.json` in the working directory (where you want to clone repositories). You can create the config file manually or you can use [init-lconf](#init-lconf) command to do it.

### start-vpn
This command is use to connect to a VPN connection using [Tunnelblick](https://tunnelblick.net/) application.

##### syntax
```start-vpn <vpn name>```

### stop-vpn
This command is use to disconnect a already connected VPN connection using [Tunnelblick](https://tunnelblick.net/) application.

##### syntax
```stop-vpn <vpn name>```

### install-talisman

This command install [Talisman](https://github.com/thoughtworks/talisman) for given git repo as a ***pre-commit*** hook.

#### syntax
```install-talisman [directory name]```

By default it takes `directory name` as current directory (`.`)

### install-talisman-all

This command does same as [install-talisman](#install-talisman) command, but only difference is this command does for all the git repo presents in current directory.

#### syntax
```install-talisman-all```

### upgrade

This commands updates **oh-my-zsh**, **brew** and **brew formula**s.

### jwtp

This commands decode payload of [**JWT**](https://jwt.io).

##### syntax
```jwtp <JWT token>```

Note: This command is originally copied from [here](https://gist.github.com/thomasdarimont/46358bc8167fce059d83a1ebdb92b0e7).

### jwth

This commands decode header of [**JWT**](https://jwt.io).

##### syntax
```jwth <JWT token>```

Note: This command is originally copied from [here](https://gist.github.com/thomasdarimont/46358bc8167fce059d83a1ebdb92b0e7).
