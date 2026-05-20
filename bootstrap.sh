#!/usr/bin/env bash
# Run all five setup scripts in order. Each script is idempotent, so this
# is safe to re-run; existing config blocks (~/.zshrc fenced markers, etc.)
# won't be duplicated.
#
# Prerequisites (NOT installed by these scripts):
#   - Homebrew (https://brew.sh/)
#   - git (used to clone this repo)
#
# Usage:  ./bootstrap.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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
