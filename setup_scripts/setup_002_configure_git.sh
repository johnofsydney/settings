echo
echo Git Config Starting...
echo

read -p "Enter your name for Git Commits: " FULL_NAME
read -p "Enter your email address Git Commits: " EMAIL

touch "$HOME/.gitignore_global"

# git + git-recent are installed in setup_001 — no need to re-install here.

############### git config setting ###############
git config --global user.name "$FULL_NAME"
git config --global user.email "$EMAIL"
git config --global core.editor "code --wait"
git config --global core.excludesfile "$HOME/.gitignore_global"
git config --global pull.rebase false
git config --global color.ui true
git config --global fetch.prune true
git config --global init.defaultBranch main
git config --global --add push.default current
git config --global --add push.autoSetupRemote true
git config --global --add merge.ff true # when possible resolve the merge as a fast-forward (only update the branch pointer to match the merged branch; do not create a merge commit)

git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true
git config --global diff.renames true

echo
echo Git Config Complete
echo run 'git config --list' to see all your Git configurations
echo