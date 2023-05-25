echo 'loading mac_settings.sh'

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

# Rectangle app settings
alias 83='open -g "rectangle://execute-action?name=bottom-right-eighth"'
alias 86='open -g "rectangle://execute-action?name=bottom-center-right-eighth"'
alias 89='open -g "rectangle://execute-action?name=top-right-eighth"'
alias 81='open -g "rectangle://execute-action?name=bottom-left-eighth"'
alias 84='open -g "rectangle://execute-action?name=bottom-center-left-eighth"'
alias 87='open -g "rectangle://execute-action?name=top-left-eighth"'


alias 99='open -g "rectangle://execute-action?name=top-right-ninth"'
alias 96='open -g "rectangle://execute-action?name=middle-right-ninth"'
alias 93='open -g "rectangle://execute-action?name=bottom-right-ninth"'
alias 97='open -g "rectangle://execute-action?name=top-left-ninth"'
alias 94='open -g "rectangle://execute-action?name=middle-left-ninth"'
alias 91='open -g "rectangle://execute-action?name=bottom-left-ninth"'

# =================================

# setopt EXTENDED_HISTORY