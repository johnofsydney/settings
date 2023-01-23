echo 'loading my_extensions.sh'

PROMPT_COMMAND='history -a'
# appends shell history to histoery on exit, rather than overwrite. maybe future improvements?


##################################################
######  non sensitive environment variables ######
export LS_COLORS="di=1;36:ln=1;35"
export EDITOR="code --wait"

export GIT_MERGE_AUTOEDIT=no

export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=1000000000
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
# alias glog="git log --oneline --graph --decorate"
# alias glo="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glog="git log --graph --all --pretty='format:%C(auto)%h %C(cyan)%ar %C(auto)%d %C(magenta)%an %C(auto)%s'"
alias gc-="git checkout -"
alias dev="git checkout develop && git fetch && git pull"
alias master="git checkout master && git fetch && git pull"
alias main="git checkout main && git fetch && git pull"

# alias recent="git recent -n10"
alias recent="git recent -n 10"
alias gp="git push"
alias gd="git diff"
alias gl="git pull"

###################################################

###################################################
######              spec aliases             ######
alias nn="npm run test_dev && eslint spec *.js"
alias be="bundle exec"
alias bep="bundle exec rake parallel:spec"
alias bepc="COVERAGE=true bundle exec rake parallel:spec"
alias ber="gd --name-only master HEAD spec/**/*spec.rb | xargs bundle exec rspec --format=documentation --profile 10"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias berdoc="bundle exec rspec --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias beer=ber
alias becop="bundle exec rubocop"
alias bb="becop && ber && grep -r -n --exclude-dir={node_modules,tmp,coverage} binding.pry ./"
alias rspec="nocorrect rspec"



alias aa="atom ."
alias cc="code ."

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias reloadz="source ~/.zshrc"
alias xx="exit"

alias readme="bat README.md"
alias schema="bat db/schema.rb"
alias weather="curl wttr.in"
alias please="sudo"

alias killspring="ps ax | grep spring | cut -f1 -d' ' | xargs kill"

function gac () {
  git add .
  git commit -m "$@"
}

function hh () {
  if [[ "$SHELL" == *"zsh"* ]]; then
    history -E 1 | grep -E "$@"
  else
    # assume it is bash.
    history -E | grep -E "$@"
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
  curl "https://code.jquery.com/jquery-3.3.1.js > js/jquery.js"
  curl "https://raw.githubusercontent.com/jashkenas/underscore/master/underscore.js > js/underscore.js"
  touch "css/main.css"
}

# function addnewline () {
#   NEWLINE=$'\n'
#   MARKER_AND_SPACE='$ '
#   PROMPT=${PROMPT}${NEWLINE}${MARKER_AND_SPACE}
# }

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
  git diff --name-status master | grep -v "^D\|^R" | grep ".rb" | awk '{print $2}' | xargs bundle exec rubocop
}




