echo
echo Begining basic setup - apps install or upgrades
echo

# Pre-flight: brew must exist. If you ran bootstrap.sh, it was installed there.
# If you're running this script standalone without brew, install it first:
#   https://brew.sh/
if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed. Run ./bootstrap.sh from the repo root, or install brew from https://brew.sh/ and re-run." >&2
  exit 1
fi

# Speed: without this, *every* `brew install` / `brew upgrade` invocation below
# git-fetches homebrew-core + homebrew-cask before doing any work. We do one
# explicit `brew update` further down when we're actually upgrading, so the
# per-command auto-update is pure overhead.
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

BREW_PREFIX="$(brew --prefix)"

read -p "Update already-installed apps? (y=upgrade them, n=skip them) [y/N]: " UPDATE_EXISTING
echo

# Speed: snapshot what's already installed, once. A per-package `brew list <name>`
# costs ~1s because it boots a Ruby process — across ~30 packages that was ~40
# seconds of pure checking, paid even when skipping upgrades. These two calls take
# ~0.05s total and answer every lookup below.
# Values are space-padded so a substring can't produce a false positive
# (e.g. `node` must not match `nodenv`).
INSTALLED_FORMULAE=" $(brew list --formula -1 | tr '\n' ' ') "
INSTALLED_CASKS=" $(brew list --cask -1 | tr '\n' ' ') "

# Only relevant when upgrading: refresh the tap metadata once, then ask brew a
# single time what is genuinely out of date. Anything absent from this list is
# skipped rather than paying for a no-op `brew upgrade` call.
# Note: `brew outdated` (like `brew upgrade`) ignores casks that self-update or
# are versioned `:latest`. Add --greedy to both if you ever want those too.
OUTDATED=" "
if [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
  echo "Refreshing Homebrew package lists (once)..."
  brew update
  OUTDATED=" $(brew outdated --quiet | tr '\n' ' ') "
  echo
fi

# `brew list` reports short names, so a tapped cask such as stablyai/orca/orca
# appears simply as `orca`. Strip the tap prefix before any lookup.
short_name() { echo "${1##*/}"; }

# True if the space-padded list in $1 contains the name in $2.
in_list() {
  case "$1" in
    *" $2 "*) return 0 ;;
    *)        return 1 ;;
  esac
}

# Installs a brew formula; upgrades it if already installed, UPDATE_EXISTING=y,
# and brew reports it as outdated.
install_formula() {
  local name=$1
  local key
  key="$(short_name "$name")"

  if in_list "$INSTALLED_FORMULAE" "$key"; then
    if [[ ! $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
      echo "Skipping $name (already installed)"
    elif in_list "$OUTDATED" "$key"; then
      echo "Upgrading $name..."
      brew upgrade "$name" 2>/dev/null || true
    else
      echo "Skipping $name (already up to date)"
    fi
  else
    brew install "$name"
    INSTALLED_FORMULAE="$INSTALLED_FORMULAE$key "
  fi
}

# Installs a brew cask; upgrades it if already installed, UPDATE_EXISTING=y,
# and brew reports it as outdated.
install_cask() {
  local name=$1
  local key
  key="$(short_name "$name")"

  if in_list "$INSTALLED_CASKS" "$key"; then
    if [[ ! $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
      echo "Skipping $name (already installed)"
    elif in_list "$OUTDATED" "$key"; then
      echo "Upgrading $name..."
      brew upgrade --cask "$name" 2>/dev/null || true
    else
      echo "Skipping $name (already up to date)"
    fi
  else
    brew install --cask --adopt "$name"
    INSTALLED_CASKS="$INSTALLED_CASKS$key "
  fi
}

echo "Reminder: create an SSH key and add it to GitHub if you haven't already:"
echo "  https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
echo

# git first — setup_002 needs it to set global config, and the repo may have
# been downloaded as a zip without git installed yet.
install_formula git
install_formula git-recent

install_cask iterm2      # standard terminal

# browsers
install_cask google-chrome
# install_cask firefox

# code editors
install_cask visual-studio-code
install_cask visual-studio-code@insiders

# utilities
install_formula bat              # a better cat
install_formula ag               # Silver Searcher; a faster grep
install_formula coreutils        # GNU coreutils; use modern LS_COLORS
install_formula gnupg
install_formula blueutil
install_formula zsh-syntax-highlighting
install_formula node
install_formula gh              # GitHub CLI, for interacting with GitHub from the terminal
install_formula tree
install_formula neovim
install_formula ripgrep
install_formula jq
install_formula hunk

# fzf needs a post-install step to wire up shell integrations, and that hook has
# to re-run whenever the binary changes.
FZF_CHANGED=n
if in_list "$INSTALLED_FORMULAE" fzf; then
  if [[ ! $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
    echo "Skipping fzf (already installed)"
  elif in_list "$OUTDATED" fzf; then
    echo "Upgrading fzf..."
    brew upgrade fzf 2>/dev/null || true
    FZF_CHANGED=y
  else
    echo "Skipping fzf (already up to date)"
  fi
else
  brew install fzf
  FZF_CHANGED=y
fi
if [[ $FZF_CHANGED == y ]]; then
  "$BREW_PREFIX/opt/fzf/install" --all --no-bash --no-fish
fi

install_cask spotify
# install_cask postman   # API client
install_cask rectangle # excellent window manager
install_cask slack     # you know what this is
install_cask fork      # Git GUI client
install_cask obsidian  # knowledge management app
install_cask orbstack  # Docker replacement for Apple Silicon
install_cask stablyai/orca/orca # AI agentic development envirionment
install_cask claude
install_cask claude-code

# Returns 0 (true) if any of the given casks are not yet installed.
any_cask_missing() {
  for name in "$@"; do
    in_list "$INSTALLED_CASKS" "$(short_name "$name")" || return 0
  done
  return 1
}

OFFICE_CASKS=(microsoft-excel microsoft-word microsoft-outlook microsoft-teams)
if any_cask_missing "${OFFICE_CASKS[@]}" || [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
  read -p "Do you want to install the Microsoft Office Apps (as separate apps)? (y/n) : " ANSWER
  echo
  if [[ $ANSWER =~ ^[Yy]$ ]]; then
    for cask in "${OFFICE_CASKS[@]}"; do
      install_cask "$cask"
    done
  fi
fi

# CLAUDE_CASKS=(claude claude-code)
# if any_cask_missing "${CLAUDE_CASKS[@]}" || [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
#   read -p "Do you want to install Claude (desktop) and Claude Code? (y/n) : " ANSWER
#   echo
#   if [[ $ANSWER =~ ^[Yy]$ ]]; then
#     for cask in "${CLAUDE_CASKS[@]}"; do
#       install_cask "$cask"
#     done
#   fi
# fi

echo
echo Finished Basic Apps Installation.
echo
