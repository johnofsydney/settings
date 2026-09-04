# Setup Scripts
These are to quickly and consistently set up a new mac.

## Before running
Almost nothing is a hard prerequisite — `bootstrap.sh` at the repo root installs Homebrew
if it's missing, and `001` installs git. That's deliberate: the repo has to work when it's
been downloaded as a zip rather than cloned.

### XCODE
`xcode-select --install`
If this doesn't work, make sure that your mac OS is up to date

### SSH key
Create one and add it to GitHub if you haven't already, otherwise cloning and pushing
won't work: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

## Running Scripts
Run `./bootstrap.sh` from the repo root to do all six in order (it prompts before each),
or run any one of them on its own. They're all idempotent.

- 001 - Install apps
  - Editors
  - Terminal
  - Browsers
  - Terminal Utilities
  - Spotify, Postman, Any other helpful apps
  - git first, so 002 has something to configure
- 002 - Configure Git
  - Consistent repeatable git config
  - creates an empty ~/.gitignore_global and points core.excludesfile at it
- 003 - Setup Dot Files
  - create .zshrc if required
  - source all of the settings, alias, env_variable files
- 004 - App Preferences
  - symlink VS Code settings and keybindings from repo into app folders
  - can add other scriptable app preferences later if possible
- 005 - Dev Runtimes
  - postgresql (asks which major version, or skip), redis, mise
  - starts both services and adds `mise activate` to .zshrc
- 006 - Claude Code Config
  - symlink the shared config in `claude/` into `~/.claude/`
  - asks whether this is the work or home machine, and links the profile it picks
  - see `claude/README.md` for what is shared and what each machine keeps to itself
