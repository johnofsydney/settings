echo 'loading personal_aliases.sh'
# this file is for personal aliases. It's not gitignored, but it is not useful for anyone else, and it won't be used for work stuff. It's just for my personal projects and general aliases that aren't work related. The work aliases are in work_aliases.sh, which is gitignored.

alias notes="cd ~/Projects/John/notes/"
alias exercisms="cd ~/Projects/John/exercisms/"
alias john="cd ~/Projects/John/"
alias lester="cd ~/Projects/lester"


##################################################
######            ssh aliases            ######
alias ssh_lester_db_server="ssh deploy@${LESTER_REMOTE_DB_HOST}"
alias ssh_lester_app_server="ssh deploy@${LESTER_REMOTE_APP_HOST}"
##################################################


function npj () {
  # has not been used for years, leaving here for posterity. creates a new project folder with some basic files and folders for a js project.
  mkdir -p "$@"
  cd "$@"
  mkdir "js"
  mkdir "css"
  touch "index.html"
  touch "README.md"
  touch "js/main.js"
  curl "https://code.jquery.com/jquery-3.3.1.js > js/jquery.js"
  curl "https://raw.githubusercontent.com/jashkenas/underscore/master/underscore.js > js/underscore.js"
  touch "css/main.css"
}

