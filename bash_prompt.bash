export PS1="\[\e[32m\]\w\[\e[m\] \n$ "
# my old prompt

# adadapted from https://gist.github.com/srguiwiz/de87bf6355717f0eede5
# more comprehensive version here: https://github.com/jcgoble3/gitstuff/blob/master/gitprompt.sh
function git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
function markup_git_branch {
  if [[ "x$1" = "x" ]]; then
    echo -e "$1"
  else
    if [[ $(git status 2> /dev/null | tail -n1) = "nothing to commit, working tree clean" ]]; then
      echo -e '\033[1;32m['"$1"']\033[0;0m'
    else
      echo -e '\033[1;31m['"$1"']\033[0;0m'
    fi
  fi
}
export PS1='\n\[\e[32m\]\w\[\e[m\] $(markup_git_branch $(git_branch)) \n$ '
source ~/.git-completion.bash