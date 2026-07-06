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

function mkcd () { mkdir -p "$1" && cd "$1"; }

function dcop () {
  # Run rubocop on the Ruby files changed on this branch vs its base branch,
  # skipping deleted/renamed files. Base is auto-detected (mirrors `worktree`):
  # develop, else origin's default branch, else main/master. Does nothing if no
  # Ruby files changed.
  local base
  if git show-ref --verify --quiet refs/heads/develop; then
    base=develop
  else
    base="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
    if [ -z "$base" ]; then
      for b in main master; do
        git show-ref --verify --quiet "refs/heads/$b" && { base=$b; break; }
      done
    fi
  fi
  : "${base:=master}"

  local files
  files=$(git diff --name-status "$base" | grep -vE '^[DR]' | awk '{print $2}' | grep -E '\.rb$')
  if [ -z "$files" ]; then
    echo "dcop: no changed Ruby files vs $base"
    return 0
  fi
  echo "$files" | xargs bundle exec rubocop
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
  # Delete local branches (and their matching origin branch), EXCEPT the
  # protected mainlines and the branch you're currently on. Uses -D, so it also
  # removes branches git can't see as merged (e.g. squash-merged PRs) — that's
  # the common case. Edit `protected` to match your team's long-lived branches.
  local protected="develop|main|master|staging|qa"
  local current
  current="$(git symbolic-ref --quiet --short HEAD)" || {
    echo "Detached HEAD (not on a branch) — aborting."; return 1
  }

  git branch --format='%(refname:short)' \
    | grep -vE "^(${protected})$" \
    | grep -vxF "$current" \
    | while read -r branch; do
        echo "Deleting local branch: $branch"
        git branch -D "$branch"
        if git ls-remote --heads origin "$branch" | grep -q .; then
          git push origin --delete "$branch"
        else
          echo "  (no remote branch '$branch' — skipping remote deletion)"
        fi
      done
}

# zsh-syntax-highlighting (brew formula, installed by setup_001). $HOMEBREW_PREFIX
# is set by `brew shellenv` in ~/.zprofile; fall back to the Apple-silicon default
# so this also works on Intel. Guarded so a missing plugin doesn't error every shell.
ZSH_SYNTAX_HL="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$ZSH_SYNTAX_HL" ] && source "$ZSH_SYNTAX_HL"