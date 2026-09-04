echo
echo "Begin Setup App Preferences"
echo "VS Code, VS Code Insiders (Need to have been opened previously)"
echo "iTerm and Rectangle preferences need to be imported from the app itself."
echo

# Symlinks vscode/settings.json + keybindings.json into VS Code and VS Code Insiders.
#
# Idempotent: re-running relinks the same targets. A pre-existing REGULAR file is moved
# to <name>.pre-settings-repo.bak rather than clobbered — the same contract setup_006
# uses, because a machine that has been in use has real settings worth not destroying.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" == */setup_scripts ]]; then
  SETTINGS_FOLDER="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  read -p "Enter folder for personal settings and config, eg Projects/John/settings (inside your home directory): " FOLDER
  SETTINGS_FOLDER="$HOME/$FOLDER"
fi

# Launching each editor once makes it create its Application Support directory. Skipped
# without complaint when the editor isn't installed — Insiders often isn't.
for editor in code code-insiders; do
  if command -v "$editor" >/dev/null 2>&1; then
    "$editor"
  else
    echo "  SKIP $editor — not installed"
  fi
done

# ---------------------------------------------------------------------------
# link <source> <destination>
#   Moves an existing regular file aside first. Leaves existing symlinks to be
#   overwritten by ln -sfn (relinking is the whole point of re-running).
# ---------------------------------------------------------------------------
link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "  SKIP $(basename "$dst") — no $src"
    return 0
  fi
  if [ ! -d "$(dirname "$dst")" ]; then
    echo "  SKIP $(basename "$dst") — $(dirname "$dst") does not exist (open the editor once first)"
    return 0
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="$dst.pre-settings-repo.bak"
    if [ -e "$backup" ]; then
      backup="$backup.$(date +%Y%m%d%H%M%S)"
    fi
    mv "$dst" "$backup"
    echo "  BACKED UP existing $(basename "$dst") -> $(basename "$backup")"
  fi
  ln -sfn "$src" "$dst"
  echo "  LINKED $(basename "$dst") -> ${src#"$HOME/"}"
}

echo
for app in "Code" "Code - Insiders"; do
  echo "$app"
  link "$SETTINGS_FOLDER/vscode/settings.json"    "$HOME/Library/Application Support/$app/User/settings.json"
  link "$SETTINGS_FOLDER/vscode/keybindings.json" "$HOME/Library/Application Support/$app/User/keybindings.json"
done

echo
echo "Finished App Preference Setup."
echo
