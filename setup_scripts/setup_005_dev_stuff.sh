brew install postgresql
brew install redis

brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

brew services start postgresql
brew services start redis

