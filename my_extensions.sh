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
alias gcm="git checkout master"

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
alias bepc="COVERAGE=true bep"
alias ber="bundle exec rspec"
alias berdoc="bundle exec rspec  --profile --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias berdiff="gd --name-only master HEAD spec/**/*spec.rb | xargs bundle exec rspec --format=documentation --profile 10"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias becop="bundle exec rubocop --parallel"

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
}

gch() {
  git checkout $(git branch | fzf| tr -d "[[:space:]]")
}

alias ch=gch

function spinup () {
  local project="$1"

  if [[ "$project" != "real" && "$project" != "lester" ]]; then
    echo "❌ Error: argument must be 'real' or 'lester'"
    return 1
  fi

  local main_dir=""
  local second_dir=""

  local console_cmd=""
  local server_cmd=""
  local secondary_cmd=""

  if [[ "$project" == "real" ]]; then
    main_dir="$HOME/Projects/realhub"
    second_dir="$HOME/Projects/realhub-frontend"
    console_cmd="bash -l -c 'rails console'"
    server_cmd="bash -l -c 'APP_SERVER=puma rails server -p 3002'"
    secondary_cmd="bash -l -c 'yarn start'"
  elif [[ "$project" == "lester" ]]; then
    main_dir="$HOME/Projects/John/lester"
    second_dir="$main_dir" # there is no seperate Frontend for lester
    console_cmd="bash -l -c 'rails console'"
    server_cmd="bash -l -c 'rails server -p 3000'"
    secondary_cmd="bash -l -c 'bundle exec sidekiq'"
  fi

  echo "Spinning up $project project..."
  echo "Main directory: $main_dir"
  echo "Second directory: $second_dir"

  osascript <<EOF
tell application "iTerm"
  activate

  -- Create a new window with the default profile
  set newWindow to (create window with profile "MaterialDesignColors")
  delay 0.5

  tell current session of newWindow
    set session1 to it
    write text "cd $main_dir"
    write text "clear"

    delay 0.5
    set session2 to (split horizontally with profile "MaterialDesignColors")
  end tell

  tell session2
    write text "cd $main_dir"
    write text "clear"
    write text "$console_cmd"

    delay 0.5
    set session3 to (split horizontally with profile "MaterialDesignColors")
  end tell

  tell session3
    write text "cd $main_dir"
    write text "clear"
    write text "$server_cmd"

    delay 0.5
    set session4 to (split vertically with profile "MaterialDesignColors")
  end tell

  tell session4
    write text "cd $second_dir"
    write text "clear"
    write text "$secondary_cmd"
  end tell
end tell

-- Optional: use Rectangle shortcut
delay 0.5
tell application "System Events"
  key code 123 using {control down, option down}
end tell
EOF
}
