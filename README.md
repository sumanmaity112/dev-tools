# dev-tools

This repository holds some custom commands to make developer life easy. 


Table of Contents
=================
   * [dev-tools](#dev-tools)
      * [Setup](#setup)
      * [Commands](#commands)
         * [pull-all](#pull-all)
         * [lc-clone](#lc-clone)

## Setup
Add this to your `~/.profile` / `.bash_profile` / `~/.zshrc` (depending
on your shell and setup):
```bash
CUSTOM_COMMANDS=path/to/dev-tools/etc/shell-init.sh
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
