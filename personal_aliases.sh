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