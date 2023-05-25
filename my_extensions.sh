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
alias john="cd ~/Projects/John/"
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
alias bep="be rake parallel:load_schema && bundle exec rake parallel:spec"
alias bepc="COVERAGE=true bep"
alias ber="bundle exec rspec"
alias berdiff="gd --name-only master HEAD spec/**/*spec.rb | xargs bundle exec rspec --format=documentation --profile 10"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"
alias berdoc="bundle exec rspec  --profile --format=documentation"
alias berf="bundle exec rspec --format=documentation --only-failures"
alias beer=ber
alias becop="bundle exec rubocop"
alias bb="becop && ber && grep -r -n --exclude-dir={node_modules,tmp,coverage} binding.pry ./"
alias rspec="nocorrect rspec"



alias aa="atom ."
alias cc="code-insiders ."

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias reloadz="source ~/.zshrc"
alias reload="source ~/.zshrc"
alias xx="exit"

alias readme="bat README.md"
alias schema="bat db/schema.rb"
alias weather="curl wttr.in"
alias please="sudo"

alias meet="open https://meet.google.com/"

alias killspring="ps ax | grep spring | cut -f1 -d' ' | xargs kill"

function gac () {
  git add .
  git commit -m "$@"
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



# FOR REFERENCE
# echo 'loading work_functions.sh'

# function load_latest_database () {
#   cd ~/Downloads

#   echo $PWD

#   MATCHING_FILES=($(ls *database*.gz))
#   LATEST_ZIPPED_FILE=${MATCHING_FILES[-1]}
#   echo "1. Loading latest database from: $LATEST_ZIPPED_FILE"

#   gunzip $LATEST_ZIPPED_FILE
#   UNZIPPED_FILE=${LATEST_ZIPPED_FILE%???}
#   echo "2. Unzipped file: $UNZIPPED_FILE"

#   echo "3. Dropping database"
#   dropdb sherpa_development

#   echo "4. Creating database"
#   createdb sherpa_development

#   echo "5. Loading database"
#   psql -d sherpa_development < $UNZIPPED_FILE

#   echo "6. Removing files"
#   rm $UNZIPPED_FILE

#   echo "7. Adding password to database"
#   cd ~/Projects/Sherpa/sherpa-backend
#   bundle exec rails runner ~/Projects/Sherpa/add_password_to_development_database.rb

#   if [ $(git status --porcelain | wc -l) -eq "0" ]; then
#     echo "🟢 Git repo is clean. Continuing...\n"
#   else
#     echo "🔴 Git repo dirty. Quit."
#     return 1
#   fi

#   echo "8. Running bundle install && db:migrate"
#   bundle install
#   bundle exec rails db:migrate
#   git checkout db/schema.rb

#   echo "9. Running post_deploy"
#   bundle exec rake post_deploy
# }