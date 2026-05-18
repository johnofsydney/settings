# settings
This whole repo is about getting setup on a fresh install quickly and for maintaining a consistent environment between machines

1. Download apps and utilities
2. Configure Git
3. Setup dot files
4. Set up scriptable app preferences

## 1. Download apps and utlities
`$ ./setup_scripts/setup_001_install_apps.sh`
- Add new apps & utilities here if they are broadly applicable
- Script is idempotent

## 2. Configure git
Rather than remembering specific git config, just run the script

`$ ./setup_scripts/setup_002_configure_git.sh`



## 3. Setup dotfiles including .zshrc
`$ ./setup_scripts/setup_003_setup_dot_files.sh`

zshrc remains the main orchestrator for all dot files
script will write `source` commands to load in settings in
- my_extensions.sh
- mac_settings.sh
- work_aliases.sh
- env_variables.sh
- prompt.sh

...
machine specific setup, eg PATH changes are out of scope for this project - of course go ahead and make specific changes as needed to  zshrc

## 4. Setup app preferences
`$ ./setup_scripts/setup_004_app_preferences.sh`
- VS Code settings and keybindings live in plain old JSON files and can be symlinked  - which is scriptable
- settings for iterm need to be imported via the iterm GUI (not scriptable AFAIK)
- settings for Rectangle need to be imported via the Rectangle GUI (not scriptable AFAIK)

### For Rectangle
In the App GUI, _Import Settings_ from this directory

### For iTerm
In the App GUI, under General / Settings, choose _Load Settings from a custom folder or URL_ and select the preferences in `settings/iterm_preferences`
