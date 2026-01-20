#!/usr/bin/env bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# XCode Command Line Tools
xcode-select --install

brew install iterm2      # terminal
brew install git
brew install git-recent

# Browsers
brew install --cask google-chrome

# Editors
brew install --cask visual-studio-code
brew install --cask visual-studio-code@insiders

# Helpful apps
brew install bat              # a better cat
brew install ag               # Silver Searcher; a faster grep
brew install --cask spotify
brew install --cask postman   # API client
brew install --cask rectangle # excellent window manager
brew install fzf              # fuzzy find, better terminal recall
$(brew --prefix)/opt/fzf/install

###################################################
############### git config setting ###############

git config --global user.name "John Coote"
git config --global user.email "john.coote@domain.com.au" # NB - username might change
git config --global core.editor code --wait
git config --global core.excludesfile /Users/john.coote/.gitignore_global # NB - username might change
git config --global pull.rebase false
git config --global color.ui true
git config --global fetch.prune true
git config --global init.defaultBranch main
git config --global --add push.default current
git config --global --add push.autoSetupRemote true
git config --global --add merge.ff true # when possible resolve the merge as a fast-forward (only update the branch pointer to match the merged branch; do not create a merge commit)

git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/jc-domain-macbook
git config --global commit.gpgsign true

###################################################

########### Some work related installs ###########
brew install pkg-config
brew install imagemagick
brew link imagemagick --force
brew install postgresql@12
brew link postgresql@12
brew install python@2
brew install python3 gcc
brew install python-setuptools
brew install nvm
brew install vips
brew install redis
brew install ghostscript
brew install pcre
brew install yarn

# RVM
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import
rvm get stable
rvm install 3.3.6
rvm use 3.3.6


brew services start postgresql@12