echo "Loading mac_settings.sh"

  # this fixes the annoying behaviour around correcting the "rspec" in "$ bundle exec rspec"
  # https://superuser.com/questions/439209/how-to-partially-disable-the-zshs-autocorrect
  # it doesn't work on linux
  unsetopt correct_all
  setopt correct

# =================================
# this is an oh-my-zsh plugin rather than a zsh default
# use `d` to list recent directories

# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

## add by me from https://apple.stackexchange.com/questions/296477/my-command-line-says-complete13-command-not-found-compdef
autoload -Uz compinit
compinit
##

compdef _dirs d

# =================================

# setopt EXTENDED_HISTORY