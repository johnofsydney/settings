echo 'loading personal_aliases.sh'
# this file is for personal aliases. It's not gitignored, but it is not useful for anyone else, and it won't be used for work stuff. It's just for my personal projects and general aliases that aren't work related. The work aliases are in work_aliases.sh, which is gitignored.

alias notes="cd ~/Projects/John/notes/"
alias exercisms="cd ~/Projects/John/exercisms/"
alias john="cd ~/Projects/John/"
alias lester="cd ~/Projects/lester"


##################################################
######            ssh aliases            ######
alias ssh_lester_db_server="ssh deploy@${LESTER_REMOTE_DB_HOST}"
alias ssh_lester_app_server="ssh deploy@${LESTER_REMOTE_APP_HOST}"
##################################################


PXC_HEADPHONES="00-16-94-20-d2-9b"
HOME_KEYBOARD="40-e6-4b-94-0b-b7"
HOME_MOUSE="30-d9-d9-95-e7-27"

alias pxc_off="blueutil --disconnect $PXC_HEADPHONES && echo 'disconnected from pxc' || echo 'failed to disconnect from pxc'"
alias pxc_on="blueutil --connect $PXC_HEADPHONES && echo 'connected to pxc' || echo 'failed to connect to pxc'"

alias connect_peripherals="blueutil --connect $HOME_MOUSE && blueutil --connect $HOME_KEYBOARD && echo 'connected to home periphals' || echo 'failed to connect to home periphals'"


##################################################
######         iTerm2 profiles           ######
# Switch the CURRENT iTerm2 session to a named profile via iTerm2's
# proprietary OSC 1337 SetProfile escape sequence. mac/iTerm-only:
# it's a silent no-op in any other terminal, so it's safe to load anywhere.
# Extend by adding a one-line alias for any profile (existing or new).

# Profile to restore to when a wrapped command (e.g. claude) exits.
: "${ITERM_DEFAULT_PROFILE:=Default}"

iterm_profile() {
  [ -z "$1" ] && { echo "usage: iterm_profile <profile-name>" >&2; return 1; }
  [ "$TERM_PROGRAM" = "iTerm.app" ] || return 0
  printf "\033]1337;SetProfile=%s\007" "$1"
}

# type `matrix` to load the Matrix profile
alias matrix='iterm_profile "Matrix"'

# Run claude under the Matrix profile, then restore the default on exit.
claude() {
  iterm_profile "Matrix"
  command claude "$@"
  local status=$?
  iterm_profile "$ITERM_DEFAULT_PROFILE"
  return $status
}
##################################################