# Setup Scripts
These are to quickly and consistently set up a new mac.

## Before running
install brew and developer tools

### BREW: install home-brew from: https://brew.sh/
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
### XCODE:
`xcode-select --install`
If this doesn't work, make sure that your mac OS is up to date

### Git
`brew install git`
Strictly speaking this is an optional step - you can just download these files from the repo without cloning. But better / more likely this whole repo is cloned with git. Thank you.

## Running Scripts
- 001 - Install apps
  - Editors
  - Terminal
  - Browsers
  - Terminal Utilities
  - Spotify, Postman, Any other helpful apps
- 002 - Configure Git
  - Consistent repeatable git config
  - add some files to global gitignore
- 003 - Setup Dot Files
  - create .zshrc if required
  - source all of the settings, alias, env_variable files
- 004 - App Preferences
  - symlink VS Code settings and keybindings from repo into app folders
  - can add other scriptable app preferences later if possible