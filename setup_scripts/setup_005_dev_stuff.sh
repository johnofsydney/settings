echo
echo Dev Stuff Setup Starting...
echo

# Pin major versions so a fresh machine doesn't get a surprise upgrade.
# Bump these when you actually want to move; un-versioned `postgresql` no
# longer resolves on current Homebrew.
brew install postgresql@15
brew install redis

brew install mise

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

brew services start postgresql@15
brew services start redis

echo
echo Dev Stuff Setup Complete
echo
