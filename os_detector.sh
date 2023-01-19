echo 'loading os_detector.sh'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "No specific options for Linux"
else
  source ~/Projects/John/settings/mac_settings.sh
fi