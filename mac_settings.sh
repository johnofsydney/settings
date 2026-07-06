echo 'loading mac_settings.sh'

# macOS-only. Bail early on other platforms so ~/.zshrc can source this
# unconditionally (see setup_003). Everything below assumes blueutil, Rectangle,
# and `open -g`, which only exist on a Mac. `return` works because we're sourced.
[[ "$OSTYPE" == darwin* ]] || return

# this fixes the annoying behaviour around correcting the "rspec" in "$ bundle exec rspec"
# https://superuser.com/questions/439209/how-to-partially-disable-the-zshs-autocorrect
# it doesn't work on linux
unsetopt correct_all
setopt correct

# =================================
# `d` lists recent directories; `1`-`9` jump to entries in that list.

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus  # makes `cd -N` mean stack position N (used by the aliases below)

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

# =================================

## add by me from https://apple.stackexchange.com/questions/296477/my-command-line-says-complete13-command-not-found-compdef
autoload -Uz compinit
compinit
##

compdef _dirs d

# =================================

# setopt EXTENDED_HISTORY

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh