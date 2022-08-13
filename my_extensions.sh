

PROMPT_COMMAND='history -a'
# appends shell history to histoery on exit, rather than overwrite. maybe future improvements?

# HISTFILESIZE=10000000
# HISTSIZE=10000000
# https://www.katescomment.com/how-to-increase-mac-osx-bash-shell-history-length/
###################################

# export LSCOLORS=gxfxcxdxbxegedabagacad
# https://geoff.greer.fm/lscolors/

##################################################
######         environment variables        ######
export LS_COLORS="di=1;36:ln=1;35"
export EDITOR="code --wait"

export GIT_MERGE_AUTOEDIT=no
##################################################

alias ls="ls -G"
alias lg="ls -laFG"
alias l="lg"

##################################################
######            folder aliases            ######
alias settings="cd ~/Projects/John/settings/"
alias notes="cd ~/Projects/John/notes/"
alias exercisms="cd ~/Projects/John/exercisms/"
##################################################

###################################################
######              git aliases              ######
alias ga="git add ."
alias gst="git status"
alias glog="git log --oneline --graph --decorate"
alias glo="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gc-="git checkout -"
alias dev="git checkout develop && git fetch && git pull"
alias master="git checkout master && git fetch && git pull"

# alias recent="git recent -n10"
alias recent="git branch --sort=-committerdate -v"
alias gp="git push"
alias gd="git diff"
alias gl="git pull"

###################################################

###################################################
######              spec aliases             ######
alias nn="npm run test_dev && eslint spec *.js"
alias be="bundle exec"
alias bep="bundle exec rake parallel:spec"
alias ber="bundle exec rspec"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias berdoc="bundle exec rspec --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias beer=ber
alias becop="bundle exec rubocop"
alias bb="becop && ber && grep -r -n --exclude-dir={node_modules,tmp,coverage} binding.pry ./"
alias rspec='nocorrect rspec'

# this fixes the annoying behaviour around correcting the "rspec" in "$ bundle exec rspec"
# https://superuser.com/questions/439209/how-to-partially-disable-the-zshs-autocorrect
# it doesn't work on linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Setting specific options for Linux"
else
  # not Linux (it me, so probably Mac).
  echo "Setting specific options for Mac"
  unsetopt correct_all
  setopt correct
fi

###################################################

alias aa="atom ."
alias cc="code ."

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias reloadz="source ~/.zshrc"
alias xx="exit"

alias cat="bat"
alias readme="cat README.md"
alias schema="cat db/schema.rb"
alias weather="curl wttr.in"
alias please="sudo"

alias crap="create-react-app"
alias cujq="curl https://code.jquery.com/jquery-3.3.1.js > js/jquery.js"
alias cuus="curl https://raw.githubusercontent.com/jashkenas/underscore/master/underscore.js > js/underscore.js"

alias killspring="ps ax | grep spring | cut -f1 -d' ' | xargs kill"

function gac () {
  git add .
  git commit -m "$@"
}

function hh () {
  if [[ "$SHELL" == *"zsh"* ]]; then
    history 1 | grep -E "$@"
  else
    # assume it is bash.
    history | grep -E "$@"
  fi
}

function mkcd () { mkdir -p "$@" && cd "$@"; }

function npj () {
  mkdir -p "$@"
  cd "$@"
  mkdir "js"
  mkdir "css"
  cujq
  cuus
  touch "index.html"
  touch "README.md"
  touch "js/main.js"
  touch "css/master.css"
  aa
}

function addnewline () {
  NEWLINE=$'\n'
  MARKER_AND_SPACE='$ '
  PROMPT=${PROMPT}${NEWLINE}${MARKER_AND_SPACE}
}

function runNested() {
  color=cyan

  for d in ./*/
    do /bin/zsh -c "
    (
      cd "$d" &&
      print -P "%F{$color}$d%f" &&
      "$@"
      echo '\n'
      )
    "
  done
}

function dcop () {
  git diff --name-status develop | grep -v "^D\|^R099" | grep ".rb" | awk '{print $2}' | xargs bundle exec rubocop
}

# =================================
# this is an oh-my-zsh plugin rather than a zsh default

# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

# alias md='mkdir -p'
# alias rd=rmdir

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

# # List directory contents
# alias lsa='ls -lah'
# alias l='ls -lah'
# alias ll='ls -lh'
# alias la='ls -lAh'
# =================================



export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=1000000000
setopt EXTENDED_HISTORY