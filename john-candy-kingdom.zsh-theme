if ! hg prompt 2>/dev/null; then
    function hg_prompt_info { }
else
    function hg_prompt_info {
        hg prompt --angle-brackets "\
< on %{$fg[magenta]%}<branch>%{$reset_color%}>\
< at %{$fg[yellow]%}<tags|%{$reset_color%}, %{$fg[yellow]%}>%{$reset_color%}>\
%{$fg[green]%}<status|modified|unknown><update>%{$reset_color%}<
patches: <patches|join( → )|pre_applied(%{$fg[yellow]%})|post_applied(%{$reset_color%})|pre_unapplied(%{$fg_bold[black]%})|post_unapplied(%{$reset_color%})>>" 2>/dev/null
    }
fi

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo ${SHORT_HOST:-$HOST}
}

# Grab the current date (%D) and time (%T) wrapped in {}: {%D %T}
# DALLAS_CURRENT_TIME_="%{$fg[white]%}{%{$fg[yellow]%}%D %T%{$fg[white]%}}%{$reset_color%}"

PROMPT='
%{$fg_bold[green]%}%~%{$reset_color%}$(hg_prompt_info)$(git_prompt_info) . %{$fg[magenta]%}%D %T
%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )$ '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[magenta]%}::"
ZSH_THEME_GIT_PROMPT_CLEAN="::%{$reset_color%} %{$fg[green]%}CLEAN 🙂 🌈 🦄"
ZSH_THEME_GIT_PROMPT_UNTRACKED="::%{$reset_color%} %{$fg[red]%}UNTRACKED FILES"
ZSH_THEME_GIT_PROMPT_DIRTY="::%{$reset_color%} %{$fg[red]%}DIRTY 💀 💩 😭"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

# RPROMPT="$DALLAS_CURRENT_TIME_%{$fg[red]%}%(?..✘)%{$reset_color%}"


# $ ln -s /path/to/original /path/to/link
# $ ln -s /Users/john/Projects/John/settings/john-candy-kingdom.zsh-theme /Users/john/.oh-my-zsh/themes/john-candy-kingdom.zsh-theme
