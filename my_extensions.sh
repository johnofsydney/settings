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
# export RUBYOPT='-W0' # suppress warnings
##################################################

alias ls="ls -G"
alias lg="ls -lah"
alias l="lg"

##################################################
######            folder aliases            ######
alias settings="cd ~/Projects/John/settings/"
alias notes="cd ~/Projects/John/notes/"
alias exercisms="cd ~/Projects/John/exercisms/"
alias john="cd ~/Projects/John/"
alias lester="cd ~/Projects/lester"
##################################################

###################################################
######              git aliases              ######
alias ga="git add ."
alias gst="git status"
alias glog="git log --graph --all --pretty='format:%C(auto)%h %C(cyan)%ar %C(auto)%d %C(magenta)%an %C(auto)%s'"
alias gc-="git checkout -"
alias dev="git checkout develop && git fetch && git pull"
alias master="git checkout master && git fetch --all && git pull"
alias main="git checkout main && git fetch --all && git pull"
alias staging="git checkout staging && git fetch && git pull"
alias qa="git checkout qa && git fetch && git pull"
alias gcm="git checkout main"
alias gmm="git merge main"

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
alias bep="bundle exec rake parallel:load_schema && bundle exec parallel_rspec -o '--profile --tag ~blob_comparison'"
alias bep-noskip="bundle exec rake parallel:load_schema && bundle exec parallel_rspec -o '--profile'"
alias bepc="COVERAGE=true bep"
alias ber="bundle exec rspec"
alias berdoc="bundle exec rspec  --profile --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias berdiff="gd --name-only master HEAD spec/**/*spec.rb | xargs bundle exec rspec --format=documentation --profile 10"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias becop="bundle exec rubocop --parallel"
alias dcop="git diff --staged --name-only --diff-filter=d | grep -E '\.(rb|rake)$' | xargs bundle exec rubocop"

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
alias weather="curl wttr.in"
alias please="sudo"

alias meet="open https://meet.google.com/"

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

function chat () {
  curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${CHAT_KEY}" \
  -d '{"prompt": "'"$@"'", "max_tokens": 1000, "model": "text-davinci-003"}' https://api.openai.com/v1/completions\?format=json | \
  jq ".choices[0].text" | \
  sed 's/\\n/\n/g' | \
  sed 's/"$//'
}

function goog () {
  echo "Searching for : $@"
  for term in $@ ; do
      echo "$term"
      search="$search%20$term"
  done
      open "http://www.google.com/search?q=$search"
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
  # gd main --name-only --diff-filter=d | grep -E '\.(rb|rake)$' | xargs bundle exec rubocop  --force-exclusion

}

gch() {
  git checkout $(git branch | fzf| tr -d "[[:space:]]")
}

alias ch=gch

function spinup_real () {
  local main_dir="$HOME/Projects/realhub" # adapt these lines to suit your own project directories
  local second_dir="$HOME/Projects/realhub-frontend" # adapt these lines to suit your own project directories
  local third_dir="$HOME/Projects/realhub-templates-frontend" # adapt these lines to suit your own project directories
  local console_cmd="bash -l -c 'rails console'"
  local server_cmd="bash -l -c 'APP_SERVER=puma rails server -p 3002'"
  local sidekiq_cmd="bash -l -c 'bundle exec sidekiq'"
  local yarn_cmd="bash -l -c 'yarn start'"

  echo "Spinning up real project..."
  echo "Main directory: $main_dir"
  echo "Second directory: $second_dir"

  osascript <<EOF
tell application "iTerm"
  activate

  -- Session 1: full width, console
  set newWindow to (create window with profile "Default")
  delay 0.5

  tell current session of newWindow
    write text "cd $main_dir"
    write text "clear"
    write text "$console_cmd"

    delay 0.5
    set session2 to (split horizontally with profile "Default")
    delay 0.5
    set session3 to (split horizontally with profile "Default")
  end tell

  -- Session 2: half width, server
  tell session2
    write text "cd $main_dir"
    write text "clear"
    write text "$server_cmd"

    delay 0.5
    set session4 to (split vertically with profile "Default")
  end tell

  -- Session 3: half width, yarn start (new)
  tell session3
    write text "cd $main_dir"
    write text "clear"
    write text "$yarn_cmd"

    delay 0.5
    set session5 to (split vertically with profile "Default")
    delay 0.5
    set session6 to (split vertically with profile "Default")
  end tell

  -- Session 4: third width, sidekiq
  tell session4
    write text "cd $main_dir"
    write text "clear"
    write text "$sidekiq_cmd"
  end tell

  -- Session 5: third width, yarn_cmd
  tell session5
    write text "cd $second_dir"
    write text "clear"
    write text "$yarn_cmd"
  end tell

  -- Session 6: third width, yarn_cmd
  tell session6
    write text "cd $third_dir"
    write text "clear"
    write text "$yarn_cmd"
  end tell
end tell

delay 0.5
tell application "System Events"
  key code 123 using {control down, option down}
end tell
EOF
}

function spinup_lester () {
  local main_dir="$HOME/Projects/John/lester"
  local console_cmd="bash -l -c 'rails console'"
  local server_cmd="bash -l -c 'rails server -p 3000'"
  local sidekiq_cmd="bash -l -c 'bundle exec sidekiq'"

  echo "Spinning up lester project..."
  echo "Main directory: $main_dir"

  osascript <<EOF
tell application "iTerm"
  activate

  set newWindow to (create window with profile "Default")
  delay 0.5

  tell current session of newWindow
    write text "cd $main_dir"
    write text "clear"
    write text "$server_cmd"

    delay 0.5
    set session2 to (split vertically with profile "Default")
  end tell

  tell session2
    write text "cd $main_dir"
    write text "clear"
    write text "$sidekiq_cmd"
  end tell

  tell current session of newWindow
    delay 0.5
    set session3 to (split horizontally with profile "Default")
  end tell

  tell session2
    delay 0.5
    set session4 to (split horizontally with profile "Default")
  end tell

  tell session3
    write text "cd $main_dir"
    write text "clear"
    write text "$console_cmd"
  end tell

  tell session4
    write text "cd $main_dir"
    write text "clear"
  end tell
end tell

delay 0.5
tell application "System Events"
  key code 123 using {control down, option down}
end tell
EOF
}

function backup_local_db () {
  echo "Creating backup on local..."

  db_name="$(basename $PWD)_development"

  pg_dump -h localhost -U postgres -d $db_name > tmp/db_backup_$(basename $PWD)_$(date +%Y%m%d_%H%M%S).sql
}

function delete_finished_branches () {
  git branch | grep -v "main\|staging" | sed 's/^[* ]*//' | while read branch; do
  git branch -D "$branch"
  git push origin --delete "$branch"
done
}