#
# File: .zshrc
# Author: eweb
# Copyright eweb, 2022-2026
# Contents:
#
# Date:          Author:  Comments:
# 18th May 2024  eweb     #0008 p4merge
#  8th Feb 2025  eweb     #0008 add asdf shims to path
# 22nd Jul 2025  eweb     #0008 comment out yarn and nvm
# 29th Jul 2025  eweb     #0008 mise intel & apple
#  4th Jun 2026  eweb     #0008 path for homebrew and mise
# 21st Jul 2026  eweb     #0008 use mise directly
#
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DISABLE_SPRING=YES
export EDITOR=emacs
export QUEST_DIR=~/projects/quest
export JIRA_USER=eweb@qstream.com
export GPG_TTY=$(tty)

autoload -Uz compinit && compinit
# autoload -Uz add-zsh-hook

unsetopt ignoreeof

bindkey "[D" backward-word
bindkey "[C" forward-word

if [[ $(uname -m) == "arm64" ]]; then
    # Commands for Apple Silicon
    eval $(/opt/homebrew/bin/brew shellenv)
else
    # Commands for Intel
    eval $(/usr/local/bin/brew shellenv)
fi

gitk() {
    `which git`k --all $1 &
}

emacsw() {
    open /Applications/Emacs.app --args --no-splash $*
}

p4merge() {
    /Applications/p4merge.app/Contents/Resources/launchp4merge $* &
}

music_list() {
    ~/projects/MusicList/build/MacOSX-*-Release/MusicList.app/Contents/MacOS/MusicList
}

bindiff() {
    diff <(xxd $1) <(xxd $2)
}

acc() {
  open ~/projects/acc/Accounts/build/MacOSX-*-Development/Accounts.app --args $1
}

frr() {
  rubocop $*
}

ave() {
    profile=$1
    shift
    aws-vault exec $profile -t $(op item get 'Qstream AWS' --totp) $*
}

connect() {
    case "$1" in
    us01)
        echo -en '\e]1;us01\e\\';
        aws-vault exec quest_prod -- ~/projects/quest/workflow/bin/connect_db us01 5443;;
    eu01)
        echo -en '\e]1;eu01\e\\';
        aws-vault exec quest_prod -- env AWS_REGION=eu-west-1 ~/projects/quest/workflow/bin/connect_db eu01 5442;;
    us02)
        aws-vault exec quest_prod -- ~/projects/quest/workflow/bin/connect_db us02 5444;;
    dev01)
        aws-vault exec quest_dev -- ~/projects/quest/workflow/bin/connect_db dev01 5440;;
    pentest01)
        aws-vault exec quest_dev -- ~/projects/quest/workflow/bin/connect_db pentest01 5441;;
    load-test)
        aws-vault exec quest_load -- ~/projects/quest/workflow/bin/connect_db load-test 5447;;
    staging01)
        aws-vault exec quest_staging -- ~/projects/quest/workflow/bin/connect_db staging01 5448;;
    sales01)
        aws-vault exec quest_sales -- ~/projects/quest/workflow/bin/connect_db sales01 5451;;
    *)
        echo "Usage: $0 {us01|us02|eu01|dev01|pentent01|load-test}";;
    esac
}

# to install intel brew on silicon
# arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ibrew() {
  arch -x86_64 /usr/local/bin/brew $*
}

kill_noted() {
  (cd `getconf DARWIN_USER_DIR` &&
       rm -rf com.apple.notificationcenter)
  rm -rf ~/Library/Group\ Containers/group.com.apple.usernoted/db2
  killall usernoted;
  killall NotificationCenter
}

export PROMPT='%u:%1d %*$ '

export PATH="$HOME/bin:$PATH"
PS1="%n %1~ %* %# "

export DJANGO_SETTINGS_MODULE=questions.settings.development

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

alias emacs="emacs -nw"

eval "$(mise activate zsh)"
