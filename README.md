# settings
bash stuff (aliases etc)
- example zshrc is below. to add settings from this folder to shell, copy relevant bits from below
vs code settings
- make a symlink from files in this folder to location that vs code expects to find settings...
   -  `ln -s /Users/john.coote/Projects/John/settings/vscode/settings.json /Users/john.coote/Library/Application\ Support/Code/User/settings.json`
   -  `ln -s /Users/john.coote/Projects/John/settings/vscode/keybindings.json /Users/john.coote/Library/Application\ Support/Code/User/keybindings.json`



.zshrc should be like this (after install oh-my-zsh)
```

  # If you come from bash you might have to change your $PATH.
  # export PATH=$HOME/bin:/usr/local/bin:$PATH

  ZSH_DISABLE_COMPFIX="true"

  # Path to your oh-my-zsh installation.
  export ZSH="/Users/john.coote/.oh-my-zsh"

  # Set name of the theme to load
  ZSH_THEME="john-candy-kingdom" # now a symlink in the themes folder
  # `ln -s ~/Projects/John/settings/john-candy-kingdom.zsh-theme ~/.oh-my-zsh/themes/john-candy-kingdom.zsh-theme`

  # Uncomment the following line to enable command auto-correction.
  ENABLE_CORRECTION="true"

  # Uncomment the following line to display red dots whilst waiting for completion.
  COMPLETION_WAITING_DOTS="true"

  # Which plugins would you like to load?
  # Standard plugins can be found in ~/.oh-my-zsh/plugins/*
  # Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
  # Example format: plugins=(rails git textmate ruby lighthouse)
  # Add wisely, as too many plugins slow down shell startup.
  plugins=(git colorize)

  source $ZSH/oh-my-zsh.sh


  source ~/Projects/John/settings/my_extensions.bash
  source ~/Projects/John/settings/work_aliases.bash

  export PATH="/usr/local/sbin:$PATH"

  ############################################################################
  #####                           ENV VARIABLES                           ####
  ############################################################################


  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
  export PATH="$PATH:$HOME/.rvm/bin"
```