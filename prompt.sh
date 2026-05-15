echo loading prompt.sh

setopt PROMPT_SUBST

# Colours
GREEN_BOLD=$'%{\x1b[1;32m%}'
MAGENTA_BOLD=$'%{\x1b[1;35m%}'
YELLOW_BOLD=$'%{\x1b[1;33m%}'
RED_BOLD=$'%{\x1b[1;31m%}'
RESET=$'%{\x1b[0m%}'

parse_git_branch_status() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if git status --porcelain 2>/dev/null | grep -q .; then
    echo "${MAGENTA_BOLD}${branch} ${RED_BOLD}| DIRTY 💀 💩 😭${RESET}"
  else
    echo "${MAGENTA_BOLD}${branch} ${GREEN_BOLD}| CLEAN 🙂 🌈 🦄${RESET}"
  fi
}

PROMPT="${YELLOW_BOLD}%*${RESET} ${GREEN_BOLD}%~${RESET} \$(parse_git_branch_status)
$ "
