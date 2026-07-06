echo 'loading my_extensions.sh'

# Append each command to $HISTFILE immediately, and share history across
# concurrent shells. PROMPT_COMMAND is a bash construct and does nothing in zsh.
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS


##################################################
######  non sensitive environment variables ######
export LS_COLORS="di=1;36:ln=1;35"
export EDITOR="code --wait"

export GIT_MERGE_AUTOEDIT=no

# Put this repo's bin/ on PATH so its scripts (e.g. `worktree`) are callable
# from any directory. $SETTINGS_FOLDER is exported by ~/.zshrc (see setup_003).
export PATH="$SETTINGS_FOLDER/bin:$PATH"

export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=1000000000
##################################################

alias ls="gls --color=auto" # gls is using GNU/linux version of ls from coreutils, which has better color support than the default mac version of ls.
alias lg="gls -lah --color=auto"
alias l="lg"

##################################################
######            folder aliases            ######
alias settings="cd ${SETTINGS_FOLDER}/"
##################################################

###################################################
######              git aliases              ######
alias ga="git add ."
alias gst="git status"
alias glog="git log --graph --all --pretty='format:%C(auto)%h %C(cyan)%ar %C(auto)%d %C(magenta)%an %C(auto)%s'"
alias gc-="git checkout -"

# Check out a branch and sync it with origin. Refuses on a dirty tree so you
# never drag uncommitted work onto another branch by accident (a dirty tree is
# exactly when you don't want an auto-pull). The dev/main/master/... aliases
# below all delegate to this.
gsync() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "gsync: not a git repo"; return 1; }
  git diff --quiet && git diff --cached --quiet || {
    echo "gsync: working tree is dirty — commit or stash first"; return 1
  }
  git checkout "$1" && git fetch --all && git pull
}
alias dev="gsync develop"
alias master="gsync master"
alias main="gsync main"
alias staging="gsync staging"
alias qa="gsync qa"
# alias gcm="git checkout main"
alias gmm="git merge main"
alias gmd="git merge develop"
alias gcb="git checkout -b"

alias recent="git recent -n 10"
alias gp="git push"
alias gd="git diff"
alias gl="git pull"

###################################################

###################################################
######              spec aliases             ######
alias rspec="nocorrect rspec"
alias config="nocorrect config"
alias be="bundle exec"
alias bep="bundle exec parallel_rspec --exclude-pattern spec/system"
alias bepc="COVERAGE=true bep"
alias ber="bundle exec rspec"
alias berdoc="bundle exec rspec  --profile --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
# alias berdiff="bundle exec rspec $(git diff --name-only develop...HEAD -- spec/ | grep '_spec\.rb$')"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias becop="bundle exec rubocop app/ spec/ --force-exclusion"

alias cc="code-insiders ."

# python/pip: there's no bare `python` on modern macOS, so these just point at
# python3/pip3. Safe today because mise doesn't manage Python here — REMOVE them
# if you ever run `mise use python@X`, or they'll shadow mise's python shim.
alias python=python3
alias pip=pip3

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias reload="source ~/.zshrc"
alias xx="exit"

export BAT_THEME="Dracula"
alias readme="bat README.md"
alias schema="bat db/schema.rb"
# alias weather="curl wttr.in"

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

function mkcd () { mkdir -p "$1" && cd "$1"; }

gch() {
  git checkout $(git branch | fzf| tr -d "[[:space:]]")
}

alias ch=gch

# zsh-syntax-highlighting (brew formula, installed by setup_001). $HOMEBREW_PREFIX
# is set by `brew shellenv` in ~/.zprofile; fall back to the Apple-silicon default
# so this also works on Intel. Guarded so a missing plugin doesn't error every shell.
ZSH_SYNTAX_HL="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$ZSH_SYNTAX_HL" ] && source "$ZSH_SYNTAX_HL"