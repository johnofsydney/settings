echo
echo "Begin Setup App Preferences"
echo "VS Code, VS Code Insiders (Need to have been opened previously)"
echo "iTerm and Rectangle perferences need to beimported from the app itself."
echo

code
code-insiders

ln -sfn "$SETTINGS_FOLDER/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
ln -sfn "$SETTINGS_FOLDER/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sfn "$SETTINGS_FOLDER/vscode/settings.json" "$HOME/Library/Application Support/Code - Insiders/User/settings.json"
ln -sfn "$SETTINGS_FOLDER/vscode/keybindings.json" "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json"

echo
echo "Finished App Preference Setup."
echo
