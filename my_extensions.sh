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
alias dev="git checkout develop && git fetch --all && git pull"
alias master="git checkout master && git fetch --all && git pull"
alias main="git checkout main && git fetch --all && git pull"
alias staging="git checkout staging && git fetch && git pull"
alias qa="git checkout qa && git fetch && git pull"
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
# alias dcop="git diff --staged --name-only --diff-filter=d | grep -E '\.(rb|rake)$' | xargs bundle exec rubocop"

alias cc="code-insiders ."

# python3 aliases
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

function mkcd () { mkdir -p "$@" && cd "$@"; }

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
  # really want to rewrite this to be more robust, but for now this is a quick way to run rubocop only on the staged files that haven't been deleted or renamed.
  git diff --name-status master | grep -v "^D\|^R" | grep ".rb" | awk '{print $2}' | xargs bundle exec rubocop
}

gch() {
  git checkout $(git branch | fzf| tr -d "[[:space:]]")
}

alias ch=gch


function backup_local_db () {
  echo "Creating backup on local..."

  db_name="$(basename $PWD)_development"

  pg_dump -h localhost -U postgres -d $db_name > tmp/db_backup_$(basename $PWD)_$(date +%Y%m%d_%H%M%S).sql
}

function delete_finished_branches () {
  git branch | sed 's/^[* ]*//' | grep -vE "^(develop|main|staging)$" | while read branch; do
  echo "Local branch: $branch"
  git branch -D "$branch"
  # Check if branch exists on remote before trying to delete
  if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
    git push origin --delete "$branch"
  else
    echo "Branch '$branch' does not exist on remote, skipping remote deletion"
  fi
done
}

# zsh-syntax-highlighting (brew formula, installed by setup_001). $HOMEBREW_PREFIX
# is set by `brew shellenv` in ~/.zprofile; fall back to the Apple-silicon default
# so this also works on Intel. Guarded so a missing plugin doesn't error every shell.
ZSH_SYNTAX_HL="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$ZSH_SYNTAX_HL" ] && source "$ZSH_SYNTAX_HL"