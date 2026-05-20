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

echo "Reminder: create an SSH key and add it to GitHub if you haven't already:"
echo "  https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
echo

# git first — setup_002 needs it to set global config, and the repo may have
# been downloaded as a zip without git installed yet.
brew install git
brew install git-recent

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