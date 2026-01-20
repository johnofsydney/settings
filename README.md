# settings
This whole repo is about saving dotfiles for getting setup on a fresh install quickly and for maintaqining consistency between machines

## .zshrc
Should look like this...
```

source ~/Projects/John/settings/oh-my-zsh-config.sh
source ~/Projects/John/settings/my_extensions.sh # above mac settings / os detector
source ~/Projects/John/settings/mac_settings.sh
source ~/Projects/John/settings/work_aliases.sh # lower down to override defaults (1) (2)
source ~/Projects/John/settings/env_variables.sh (2)

...
And then any of the machine specific setup, eg PATH changes
```

(1) choose work or home as needed
(2) should be gitignored

## Sync Up OR Import application settings

### For VS Code (standard and insiders editions)
```
$ ln -s /Users/john.coote/Projects/John/settings/vscode/keybindings.json /Users/john.coote/Library/Application\ Support/Code/User/keybindings.json
$ ln -s /Users/john.coote/Projects/John/settings/vscode/settings.json /Users/john.coote/Library/Application\ Support/Code/User/settings.json
$ ln -s /Users/john.coote/Projects/John/settings/vscode/settings.json /Users/john.coote/Library/Application\ Support/Code\ -\ Insiders/User/settings.json
$ ln -s /Users/john.coote/Projects/John/settings/vscode/keybindings.json /Users/john.coote/Library/Application\ Support/Code\ -\ Insiders/User/keybindings.json
```

### For Oh-My-Zsh theme
```
$ ln -s ~/Projects/John/settings/john-candy-kingdom.zsh-theme ~/.oh-my-zsh/themes/john-candy-kingdom.zsh-theme
```

### For Rectangle
In the App GUI, _Import Settings_ from this directory

### For iTerm
In the App GUI, under General / Settings, choose _Load Settings from a custom folder or URL_ and select the preferences in `settings/iterm_preferences`