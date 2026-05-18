echo loading prompt.sh

setopt PROMPT_SUBST

# Colours
GREEN_BOLD=$'%{\x1b[1;32m%}'
MAGENTA_BOLD=$'%{\x1b[1;35m%}'
CYAN_BOLD=$'%{\x1b[1;36m%}'
YELLOW_BOLD=$'%{\x1b[1;33m%}'
RED_BOLD=$'%{\x1b[1;31m%}'
BLUE_BOLD=$'%{\x1b[1;34m%}'
WHITE_BOLD=$'%{\x1b[1;37m%}'
RESET=$'%{\x1b[0m%}'

parse_git_branch_status() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if git status --porcelain 2>/dev/null | grep -q .; then
    echo "${MAGENTA_BOLD}${branch} ${RED_BOLD}DIRTY 💀 💩 😭${RESET}"
  else
    echo "${MAGENTA_BOLD}${branch} ${GREEN_BOLD}CLEAN 🙂 🌈 🦄${RESET}"
  fi
}

parse_mise_ruby_version() {
  # must be inside a project tracked by mise
  command -v mise >/dev/null 2>&1 || return

  local ruby_version
  ruby_version=$(mise current 2>/dev/null | grep '^ruby' | awk '{print $2}')

  [ -n "$ruby_version" ] && echo "${CYAN_BOLD}ruby ${ruby_version}${RESET}"
}

PROMPT="${YELLOW_BOLD}%*${RESET} ${GREEN_BOLD}%~${RESET} \$(parse_git_branch_status) \$(parse_mise_ruby_version)
$ "