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
  # One `git status --porcelain --branch` call yields both the branch name and
  # the dirty/clean state — the old prompt spent three git invocations per line.
  local out branch
  out=$(git status --porcelain --branch 2>/dev/null) || return  # not a git repo

  branch=${out%%$'\n'*}   # line 1: "## <branch>...<upstream> [ahead/behind]"
  branch=${branch#\#\# }  # strip leading "## "
  branch=${branch%%...*}  # strip "...upstream" and anything after it
  branch=${branch%% *}    # strip " [ahead N]" when there's no upstream marker

  # Dirty when there's any porcelain entry beyond the "## ..." header line.
  if [[ "$out" == *$'\n'* ]]; then
    echo "${MAGENTA_BOLD}${branch} ${RED_BOLD}DIRTY 💀 💩 😭${RESET}"
  else
    echo "${MAGENTA_BOLD}${branch} ${GREEN_BOLD}CLEAN 🙂 🌈 🦄${RESET}"
  fi
}

parse_mise_versions() {
  # Single `mise current` call renders both ruby and node. mise startup is the
  # expensive part, so the old prompt (one call per language) paid it twice.
  command -v mise >/dev/null 2>&1 || return

  mise current 2>/dev/null | awk \
    -v c="$CYAN_BOLD" -v w="$WHITE_BOLD" -v r="$RESET" '
      $1=="ruby"{ruby=$2} $1=="node"{node=$2}
      END {
        s=""
        if (ruby != "") s = s c "ruby " ruby r " "
        if (node != "") s = s w "node " node r
        print s
      }'
}

PROMPT="${YELLOW_BOLD}%*${RESET} ${GREEN_BOLD}%~${RESET} \$(parse_git_branch_status) \$(parse_mise_versions)
$ "