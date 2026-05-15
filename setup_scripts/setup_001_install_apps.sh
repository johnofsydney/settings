echo
echo Begining basic setup - apps install
echo homebrew must be installed already!
echo git should be installed already, how else did you get this far?
echo brew install git
echo create an SSH key and add it to github https://docs.github.com/en/authentication/connecting-to-github-with-ssh
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

#
brew install --cask spotify
brew install --cask postman   # API client
brew install --cask rectangle # excellent window manager
brew install --cask slack
brew install --cask fork

echo
echo Finished Basic Apps Installation.
echo