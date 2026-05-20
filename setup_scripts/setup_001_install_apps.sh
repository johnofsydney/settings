echo
echo Begining basic setup - apps install
echo

# Pre-flight: brew and git must already exist. We do NOT auto-install either
# — git is needed to clone this repo in the first place, and brew is treated
# as a hand-installed prerequisite to keep the scripts simple and explicit.
if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed. Install it from https://brew.sh/ and re-run." >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed — you need it to have cloned this repo." >&2
  exit 1
fi

echo "Reminder: create an SSH key and add it to GitHub if you haven't already:"
echo "  https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
echo

brew install iterm2      # standard terminal

# browsers
brew install --cask google-chrome
brew install --cask firefox

# code editors
brew install --cask visual-studio-code
brew install --cask visual-studio-code@insiders

# utilities
brew install bat              # a better cat
brew install ag               # Silver Searcher; a faster grep
brew install fzf              # fuzzy find, better terminal recall
$(brew --prefix)/opt/fzf/install
brew install coreutils        # GNU coreutils; use modern LS_COLORS
brew install gnupg
brew install blueutil

#
brew install --cask spotify
brew install --cask postman   # API client
brew install --cask rectangle # excellent window manager
brew install --cask slack
brew install --cask fork

read -p "Do you want to install the Microsoft Office Apps (as separate apps)? (y/n) : " ANSWER
echo

if [[ $ANSWER =~ ^[Yy]$ ]]; then
  brew install --cask microsoft-excel
  brew install --cask microsoft-word
  brew install --cask microsoft-outlook
  brew install --cask microsoft-teams
fi

echo
echo Finished Basic Apps Installation.
echo