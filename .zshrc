#
# File: .zshrc
# Author: eweb
# Copyright eweb, 2022-2022
# Contents:
#
# Date:          Author:  Comments:
#
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export DISABLE_SPRING=YES
export EDITOR=emacs

autoload -Uz compinit && compinit
# autoload -Uz add-zsh-hook

unsetopt ignoreeof

bindkey "[D" backward-word
bindkey "[C" forward-word

gitk() {
    `which git`k --all $1 &
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
  flog $*
  reek $*
  rubocop $*
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

export PATH="$PATH:$HOME/bin"
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/bin:/usr/local/bin:$HOME/.rvm/bin"
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
