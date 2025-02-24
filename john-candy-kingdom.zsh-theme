function ruby_version {
  echo "%{$fg_bold[blue]%}$(ruby -v | awk '{print $2}')%{$reset_color%}"
}

function date_and_time {
  echo "%{$fg_bold[magenta]%}%D %T%  | %{$reset_color%}"
}

function working_directory {
  echo "%{$fg_bold[green]%}%~%{$reset_color%}"
}

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo ${SHORT_HOST:-$HOST}
}

PROMPT='
$(date_and_time)$(working_directory)$(git_prompt_info) $(ruby_version)
%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )$ '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg_bold[magenta]%}| "
ZSH_THEME_GIT_PROMPT_CLEAN=" |%{$reset_color%} %{$fg_bold[green]%}CLEAN 🙂 🌈 🦄"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$reset_color%} %{$fg[red]%}UNTRACKED FILES"
ZSH_THEME_GIT_PROMPT_DIRTY=" |%{$reset_color%} %{$fg_bold[red]%}DIRTY 💀 💩 😭"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
