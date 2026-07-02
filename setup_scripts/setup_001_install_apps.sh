echo
echo Begining basic setup - apps install
echo

# Pre-flight: brew must exist. If you ran bootstrap.sh, it was installed there.
# If you're running this script standalone without brew, install it first:
#   https://brew.sh/
if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed. Run ./bootstrap.sh from the repo root, or install brew from https://brew.sh/ and re-run." >&2
  exit 1
fi

read -p "Update already-installed apps? (y=upgrade them, n=skip them) [y/n]: " UPDATE_EXISTING
echo

# Installs a brew formula; upgrades it if already installed and UPDATE_EXISTING=y.
install_formula() {
  local name=$1
  if brew list "$name" &>/dev/null; then
    if [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
      echo "Upgrading $name..."
      brew upgrade "$name" 2>/dev/null || true
    else
      echo "Skipping $name (already installed)"
    fi
  else
    brew install "$name"
  fi
}

# Installs a brew cask; upgrades it if already installed and UPDATE_EXISTING=y.
install_cask() {
  local name=$1
  if brew list --cask "$name" &>/dev/null; then
    if [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
      echo "Upgrading $name..."
      brew upgrade --cask "$name" 2>/dev/null || true
    else
      echo "Skipping $name (already installed)"
    fi
  else
    brew install --cask --adopt "$name"
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
install_cask firefox

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


# fzf needs a post-install step to wire up shell integrations
if brew list fzf &>/dev/null; then
  if [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
    echo "Upgrading fzf..."
    brew upgrade fzf 2>/dev/null || true
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
  else
    echo "Skipping fzf (already installed)"
  fi
else
  brew install fzf
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
fi

install_cask spotify
install_cask postman   # API client
install_cask rectangle # excellent window manager
install_cask slack     # you know what this is
install_cask fork      # Git GUI client
install_cask obsidian  # knowledge management app

# Returns 0 (true) if any of the given casks are not yet installed.
any_cask_missing() {
  for name in "$@"; do
    brew list --cask "$name" &>/dev/null || return 0
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

CLAUDE_CASKS=(claude claude-code)
if any_cask_missing "${CLAUDE_CASKS[@]}" || [[ $UPDATE_EXISTING =~ ^[Yy]$ ]]; then
  read -p "Do you want to install Claude (desktop) and Claude Code? (y/n) : " ANSWER
  echo
  if [[ $ANSWER =~ ^[Yy]$ ]]; then
    for cask in "${CLAUDE_CASKS[@]}"; do
      install_cask "$cask"
    done
  fi
fi

echo
echo Finished Basic Apps Installation.
echo