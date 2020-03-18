

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
alias reloadbash="source ~/.bash_profile"
alias reloadz="source ~/.zshrc"
# alias atombashprofile="atom ~/.bash_profile && atom ~/Projects/John/settings/"
alias settings="no"
# alias settings="cd ~/Projects/John/settings/  && code . && code ~/.bash_profile && code ~/.zshrc"

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
alias beer=ber
alias becop="bundle exec rubocop"
alias bb="ber && becop && grep -r -n --exclude-dir={node_modules,tmp,coverage} binding.pry ./"

function gac () {
  git add .
  git commit -m "$@"
}
function hh () {
  history | grep "$@"
}

function mkcd () { mkdir -p "$@" && cd "$@"; }



function shell-z () {
  chsh -s /bin/zsh
  tab
}
function shell-b () {
  chsh -s /bin/bash
  tab
}
#!/bin/bash
#
# Open new Terminal tabs from the command line
#
# Author: Justin Hileman (http://justinhileman.com)
#
# Installation:
#     Add the following function to your `.bashrc` or `.bash_profile`,
#     or save it somewhere (e.g. `~/.tab.bash`) and source it in `.bashrc`
#
# Usage:
#     tab                   Opens the current directory in a new tab
#     tab [PATH]            Open PATH in a new tab
#     tab [CMD]             Open a new tab and execute CMD
#     tab [PATH] [CMD] ...  You can prob'ly guess
# # Only for teh Mac users
# [ `uname -s` != "Darwin" ] && return
#  https://gist.github.com/bobthecow/757788
function tab () {
  echo "Making a new tab..."
    local cdto="$PWD"
    local args="$@"
    if [ -d "$1" ]; then
        cdto=`cd "$1"; pwd`
        args="${@:2}"
    fi
    osascript -i <<EOF
        tell application "iTerm2"
                tell current window
                        create tab with default profile
                        tell the current session
                                # write text "cd \"$cdto\" && $args"
                        end tell
                end tell
        end tell
EOF
}



      # ####################################################
      # ####           better cd with history           ####
      # ####################################################
      # # from https://aijaz.net/2010/02/20/navigating-the-directory-stack-in-bash/index.html

      # # An enhanced 'cd' - push directories
      # # onto a stack as you navigate to it.
      # #
      # # The current directory is at the top
      # # of the stack.
      # #
      # # retaining "dirs -c" to clear list, so as to not forget
      # # what is under the hood.

      # function stack_cd {
      #     if [ $1 ]; then
      #         # use the pushd bash command to push the directory
      #         # to the top of the stack, and enter that directory
      #         pushd "$1" > /dev/null
      #     else
      #         # the normal cd behavior is to enter $HOME if no
      #         # arguments are specified
      #         pushd $HOME > /dev/null
      #     fi
      #     # clear
      #     ls
      # }
      # # the cd command is now an alias to the stack_cd function
      # #
      # alias cd=stack_cd
      # # Swap the top two directories on the stack
      # #
      # function swap {
      #     pushd > /dev/null
      # }
      # # s is an alias to the swap function
      # alias s=swap
      # # Pop the top (current) directory off the stack
      # # and move to the next directory
      # #
      # function pop_stack {
      #     popd > /dev/null
      # }
      # alias p=pop_stack
      # # Display the stack of directories and prompt
      # # the user for an entry.
      # #
      # # If the user enters 'p', pop the stack.
      # # If the user enters a number, move that
      # # directory to the top of the stack
      # # If the user enters 'q', don't do anything.
      # #
      # function display_stack
      # {
      #     dirs -v
      #     echo -n "#: "
      #     read dir
      #     if [[ $dir = 'p' ]]; then
      #         pushd > /dev/null
      #     elif [[ $dir != 'q' ]]; then
      #         d=$(dirs -l +$dir);
      #         popd +$dir > /dev/null
      #         pushd "$d" > /dev/null
      #     fi
      # }
      # alias d=display_stack


###########################

alias crap="create-react-app"
alias cujq="curl https://code.jquery.com/jquery-3.3.1.js > js/jquery.js"
alias cuus="curl https://raw.githubusercontent.com/jashkenas/underscore/master/underscore.js > js/underscore.js"

alias killspring="ps ax | grep spring | cut -f1 -d' ' | xargs kill"



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
