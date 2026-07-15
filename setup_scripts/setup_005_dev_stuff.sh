echo
echo Dev Stuff Setup Starting...
echo

# Pin major versions so a fresh machine doesn't get a surprise upgrade —
# un-versioned `postgresql` no longer resolves on current Homebrew. Prompt
# rather than hard-code so the answer matches whatever the project on this
# machine actually needs. Press enter to accept the default; type `skip` to
# skip Postgres entirely.
DEFAULT_PG_VERSION=18
read -p "PostgreSQL major version to install [${DEFAULT_PG_VERSION}, or 'skip']: " PG_VERSION
PG_VERSION="${PG_VERSION:-$DEFAULT_PG_VERSION}"

if [[ "$PG_VERSION" == "skip" ]]; then
  echo "Skipping Postgres install."
  PG_FORMULA=""
else
  PG_FORMULA="postgresql@${PG_VERSION}"
  brew install "$PG_FORMULA"
fi

brew install redis

brew install mise
mise settings node.corepack=true

# Append mise activation to ~/.zshrc only once — fenced marker mirrors setup_003.
MISE_MARKER="# >>> mise activate (setup_005) >>>"
MISE_END_MARKER="# <<< mise activate (setup_005) <<<"
if grep -qF -- "$MISE_MARKER" "$HOME/.zshrc" 2>/dev/null; then
  echo "~/.zshrc already contains the mise activation block — skipping append."
else
  cat <<EOF >> "$HOME/.zshrc"
$MISE_MARKER
eval "\$(mise activate zsh)"
$MISE_END_MARKER

EOF
fi

if [[ -n "$PG_FORMULA" ]]; then
  brew services start "$PG_FORMULA"
fi
brew services start redis

echo
echo Dev Stuff Setup Complete
echo
