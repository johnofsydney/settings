echo 'loading os_detector.sh'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Setting specific options for Linux"
else
  # not Linux (it me, so probably Mac).
  echo "Setting specific options for Mac"

  source ~/Projects/John/settings/mac_settings.sh
fi