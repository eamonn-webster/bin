#
# File: .zshrc
# Author: eweb
# Copyright eweb, 2022-2024
# Contents:
#
# Date:          Author:  Comments:
# 18th May 2024  eweb     #0008 p4merge
#
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DISABLE_SPRING=YES
export EDITOR=emacs
export QUEST_DIR=~/projects/quest
export JIRA_USER=eweb@qstream.com

autoload -Uz compinit && compinit
# autoload -Uz add-zsh-hook

unsetopt ignoreeof

bindkey "[D" backward-word
bindkey "[C" forward-word

gitk() {
    `which git`k --all $1 &
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
  reek $*
  rubocop $*
}
  # flog $*

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
    dev01-migration)
	aws-vault exec quest_dev -- ~/projects/quest/workflow/bin/connect_db dev01 5451 -migration;;
    us01-migration)
	aws-vault exec quest_prod -- ~/projects/quest/workflow/bin/connect_db us01 5449 -migration;;
    us02-migration)
	aws-vault exec quest_prod -- ~/projects/quest/workflow/bin/connect_db us02 5450 -migration;;
    eu01-migration)
	aws-vault exec quest_prod -- env AWS_REGION=eu-west-1 ~/projects/quest/workflow/bin/connect_db eu01 5459 -migration;;
    *)
        echo "Usage: $0 {us01|us02|eu01|dev01|pentent01|load-test}";;
    esac
}

# needed to sudo because /usr/local is protected
#$ arch -x86_64 zsh
#$ cd /usr/local &&  mkdir homebrew
#$ curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew

ibrew() {
  arch -x86_64 /usr/local/bin/brew $*
}

kill_noted() {
  (cd `getconf DARWIN_USER_DIR` &&
   rm -rf com.apple.notificationcenter)
  killall usernoted;
  killall NotificationCenter
}

# function gitky() {  `which gitk` --all $1 & }

export PROMPT='%u:%1d %*$ '
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"

export PATH="$PATH:$HOME/bin:/usr/local/bin"
PS1="%n %1~ %* %# "

# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# set-window-title() {
#   window_title="\e]0;${PWD##*/}\a"
#   echo -ne "$window_title"
# }

# PR_TITLEBAR=''
# set-window-title
# add-zsh-hook precmd set-window-title

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export DJANGO_SETTINGS_MODULE=questions.settings.development

# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

source "$(brew --prefix asdf)/libexec/asdf.sh"
export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"
