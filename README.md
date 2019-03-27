# dev-tools

This repository holds some custom commands to make developer life easy. 


Table of Contents
=================
   * [dev-tools](#dev-tools)
      * [Setup](#setup)
      * [Commands](#commands)
         * [pull-all](#pull-all)
         * [lc-clone](#lc-clone)
         * [start-vpn](#start-vpn)
         * [stop-vpn](#stop-vpn)
         * [install-talisman](#install-talisman)
         * [install-talisman-all](#install-talisman-all)

## Setup
Add this to your `~/.profile` / `.bash_profile` / `~/.zshrc` (depending
on your shell and setup):
```bash
CUSTOM_COMMANDS=path/to/dev-tools/shell-functions.sh
[ -f $CUSTOM_COMMANDS ] && . $CUSTOM_COMMANDS
```

## Commands
### pull-all
This command is use to pull latest code for all the git repositiories present in the current directiory from remote.

### lc-clone
This command is use to clone a git repository and configure *git username*, *committer name* and *signkey* only for the same repository. This commands currently works with **ssh** configs. Please check this [link](https://gist.github.com/Jonalogy/54091c98946cfe4f8cdab2bea79430f9) (till step 3) for more info about ssh config.
For this command to work properly you have to create `.config.json` in the working directory (where you want to clone repository). Check the following example for valid format of `.config.json`

```json
{
    "git_username":"janedoe",
    "committer_name": "Jane Doe",
    "email": "janedoe123@mail.com",
    "signkey": "76232YRH8D"
}
```
Here **git_username** defines the github username, **committer_name** defines the actual name for the user, **email** defines the E-mail id associate with the given github userId and **signkey** defines the gpg signkey. Check this link to know more about [how to create new GPG key](https://help.github.com/en/articles/generating-a-new-gpg-key).

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
