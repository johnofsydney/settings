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


# Append the settings block to ~/.zshrc, but only once. A fenced marker lets us
# detect a prior run so re-running this script doesn't duplicate the block.
ZSHRC_MARKER="# >>> settings repo (setup_003) >>>"
ZSHRC_END_MARKER="# <<< settings repo (setup_003) <<<"
if grep -qF -- "$ZSHRC_MARKER" "$HOME/.zshrc" 2>/dev/null; then
  echo "~/.zshrc already contains the settings block — skipping append."
else
  cat <<EOF >> ~/.zshrc
$ZSHRC_MARKER
export SETTINGS_FOLDER="$SETTINGS_FOLDER"
source "$SETTINGS_FOLDER/env_variables.sh" # gitignored
source "$SETTINGS_FOLDER/my_extensions.sh" # above mac_settings (self-guards on macOS)
source "$SETTINGS_FOLDER/mac_settings.sh"
source "$SETTINGS_FOLDER/work_aliases.sh"  # gitignored
source "$SETTINGS_FOLDER/personal_aliases.sh"
source "$SETTINGS_FOLDER/prompt.sh"
$ZSHRC_END_MARKER

EOF
fi

echo
echo Setup Dot Files Complete
echo