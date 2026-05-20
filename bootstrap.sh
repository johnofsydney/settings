#!/usr/bin/env bash
# Bootstrap a fresh Mac from this repo, even if the repo was downloaded as a
# zip rather than cloned (git isn't required to be installed yet).
#
# Order of operations:
#   1. Install Homebrew if it's missing.
#   2. Run the five numbered setup scripts in order, prompting before each.
#      (setup_001 installs git, setup_002 configures it, etc.)
#
# Every script is idempotent, so this is safe to re-run.
#
# Usage:  ./bootstrap.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

############################################################
# Homebrew install (only if missing)
############################################################
if ! command -v brew >/dev/null 2>&1; then
  echo
  echo "Homebrew not found — installing from https://brew.sh/"
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Make `brew` available in this shell session immediately. Apple Silicon
  # installs to /opt/homebrew; Intel installs to /usr/local. Try both.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  # Persist `brew shellenv` into ~/.zprofile so future shells find brew on PATH
  # before ~/.zshrc runs. Fenced marker keeps this idempotent.
  BREW_MARKER="# >>> homebrew shellenv (bootstrap) >>>"
  BREW_END_MARKER="# <<< homebrew shellenv (bootstrap) <<<"
  touch "$HOME/.zprofile"
  if ! grep -qF -- "$BREW_MARKER" "$HOME/.zprofile" 2>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    cat <<EOF >> "$HOME/.zprofile"
$BREW_MARKER
eval "\$($BREW_PREFIX/bin/brew shellenv)"
$BREW_END_MARKER

EOF
  fi
else
  echo "Homebrew already installed: $(brew --prefix)"
fi

############################################################
# Numbered setup scripts
############################################################
for script in \
  setup_scripts/setup_001_install_apps.sh \
  setup_scripts/setup_002_configure_git.sh \
  setup_scripts/setup_003_setup_dot_files.sh \
  setup_scripts/setup_004_app_preferences.sh \
  setup_scripts/setup_005_dev_stuff.sh
do
  echo
  echo "================================================================"
  echo "Running $script"
  echo "================================================================"
  read -p "Run this step? (y/n/q) : " ANSWER
  case "$ANSWER" in
    [Yy]*) bash "$script" ;;
    [Qq]*) echo "Bootstrap aborted."; exit 0 ;;
    *)     echo "Skipping $script." ;;
  esac
done

echo
echo "Bootstrap complete. Open a new shell so ~/.zshrc takes effect."
echo
