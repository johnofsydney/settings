

PROMPT_COMMAND='history -a'
# appends shell history to histoery on exit, rather than overwrite. maybe future improvements?

HISTFILESIZE=10000000
HISTSIZE=10000000
# https://www.katescomment.com/how-to-increase-mac-osx-bash-shell-history-length/
###################################

# export LSCOLORS=gxfxcxdxbxegedabagacad
# https://geoff.greer.fm/lscolors/

export LS_COLORS="di=1;36:ln=1;35"

alias ls="ls -G"
alias lg="ls -laFG"

alias reloadz="source ~/.zshrc"

alias settings="cd ~/Projects/John/settings/ && code ~/Projects/John/settings/  && code ~/.zshrc"

alias aa="atom ."
alias cc="code ."
alias xx="exit"
alias ga="git add ."
alias gst="git status"
alias glog="git log --oneline --graph --decorate"
alias glo="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gc-="git checkout -"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cat="bat"
alias nn="npm run test_dev && eslint spec *.js"
alias be="bundle exec"
alias ber="bundle exec rspec"
alias berdoc="bundle exec rspec --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias beer=ber
alias becop="bundle exec rubocop"
alias bb="ber && becop && grep -r --exclude-dir={node_modules,tmp,coverage} binding.pry ./"

alias crap="create-react-app"
alias cujq="curl https://code.jquery.com/jquery-3.3.1.js > js/jquery.js"
alias cuus="curl https://raw.githubusercontent.com/jashkenas/underscore/master/underscore.js > js/underscore.js"

alias killspring="ps ax | grep spring | cut -f1 -d' ' | xargs kill"

function gac () {
  git add .
  git commit -m "$@"
}

function hh () {
  history | grep "$@"
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