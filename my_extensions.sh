

PROMPT_COMMAND='history -a'
# appends shell history to histoery on exit, rather than overwrite. maybe future improvements?

HISTFILESIZE=10000000
HISTSIZE=10000000
# https://www.katescomment.com/how-to-increase-mac-osx-bash-shell-history-length/
###################################

# export LSCOLORS=gxfxcxdxbxegedabagacad
# https://geoff.greer.fm/lscolors/

##################################################
######         environment variables        ######
export LS_COLORS="di=1;36:ln=1;35"
export EDITOR="code --wait"
##################################################

alias ls="ls -G"
alias lg="ls -laFG"
alias l="lg"

##################################################
######            folder aliases            ######
alias settings="cd ~/Projects/John/settings/"
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
alias recent="git recent -n10"
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
unsetopt correct_all
setopt correct
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
  history | grep -E "$@"
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
