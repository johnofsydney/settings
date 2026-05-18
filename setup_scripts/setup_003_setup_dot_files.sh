echo
echo Setup Dot Files Starting...
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" == */setup_scripts ]]; then
  SETTINGS_FOLDER="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  read -p "Enter folder for personal settings and config, eg Projects/John/settings (inside your home directory): " FOLDER
  SETTINGS_FOLDER="$HOME/$FOLDER"
fi

mkdir -p "$SETTINGS_FOLDER"

export SETTINGS_FOLDER # make this available to the rest of the setup scripts, and also to the .zshrc file that will be sourcing the individual settings files in this folder

touch "$HOME/.zshrc"
touch "$SETTINGS_FOLDER/work_aliases.sh"
touch "$SETTINGS_FOLDER/env_variables.sh"

touch "$HOME/.gitignore_global" # should be created already, but double check and create if not
echo "$SETTINGS_FOLDER/work_aliases.sh" >> "$HOME/.gitignore_global"
echo "$SETTINGS_FOLDER/env_variables.sh" >> "$HOME/.gitignore_global"


cat <<EOF >> ~/.zshrc
export SETTINGS_FOLDER="$SETTINGS_FOLDER"

source "$SETTINGS_FOLDER/my_extensions.sh" # above mac settings / os detector
source "$SETTINGS_FOLDER/mac_settings.sh"
source "$SETTINGS_FOLDER/work_aliases.sh"  # gitignored
source "$SETTINGS_FOLDER/env_variables.sh" # gitignored
source "$SETTINGS_FOLDER/prompt.sh"

EOF

echo
echo Setup Dot Files Complete
echo