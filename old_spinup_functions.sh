# archive these, might be somewhat useful later, but for now just want to keep my_extensions.sh clean and focused on the aliases

function spinup_real () {
  local main_dir="$HOME/Projects/realhub" # adapt these lines to suit your own project directories
  local second_dir="$HOME/Projects/realhub-frontend" # adapt these lines to suit your own project directories
  local third_dir="$HOME/Projects/realhub-templates-frontend" # adapt these lines to suit your own project directories
  local console_cmd="bash -l -c 'bundle exec rails console'"
  local server_cmd="bash -l -c 'APP_SERVER=puma ./bin/rails server -p 3002'"
  local sidekiq_cmd="bash -l -c 'bundle exec sidekiq'"
  local yarn_cmd="bash -l -c 'yarn start'"

  echo "Spinning up real project..."
  echo "Main directory: $main_dir"
  echo "Second directory: $second_dir"

  osascript <<EOF
tell application "iTerm"
  activate

  -- Session 1: full width, console
  set newWindow to (create window with profile "Default")
  delay 0.5

  tell current session of newWindow
    write text "cd $main_dir"
    write text "clear"
    write text "$console_cmd"

    delay 0.5
    set session2 to (split horizontally with profile "Matrix")
    delay 0.5
    set session3 to (split horizontally with profile "MaterialDesignColors")
  end tell

  -- Session 2: half width, server
  tell session2
    write text "cd $main_dir"
    write text "clear"
    write text "$server_cmd"

    delay 0.5
    set session4 to (split vertically with profile "Matrix")
  end tell

  -- Session 3: half width, yarn start (new)
  tell session3
    write text "cd $main_dir"
    write text "clear"
    write text "$yarn_cmd"

    delay 0.5
    set session5 to (split vertically with profile "MaterialDesignColors")
    delay 0.5
    set session6 to (split vertically with profile "MaterialDesignColors")
  end tell

  -- Session 4: third width, sidekiq
  tell session4
    write text "cd $main_dir"
    write text "clear"
    write text "$sidekiq_cmd"
  end tell

  -- Session 5: third width, yarn_cmd
  tell session5
    write text "cd $second_dir"
    write text "clear"
    write text "$yarn_cmd"
  end tell

  -- Session 6: third width, yarn_cmd
  tell session6
    write text "cd $third_dir"
    write text "clear"
    write text "$yarn_cmd"
  end tell
end tell

delay 0.5
tell application "System Events"
  key code 123 using {control down, option down}
end tell
EOF
}

function spinup_lester () {
  local main_dir="$HOME/Projects/John/lester"
  local console_cmd="bash -l -c 'rails console'"
  local server_cmd="bash -l -c 'rails server -p 3000'"
  local sidekiq_cmd="bash -l -c 'bundle exec sidekiq'"

  echo "Spinning up lester project..."
  echo "Main directory: $main_dir"

  osascript <<EOF
tell application "iTerm"
  activate

  set newWindow to (create window with profile "Matrix")
  delay 0.5

  tell current session of newWindow
    write text "cd $main_dir"
    write text "clear"
    write text "$server_cmd"

    delay 0.5
    set session2 to (split vertically with profile "Matrix")
  end tell

  tell session2
    write text "cd $main_dir"
    write text "clear"
    write text "$sidekiq_cmd"
  end tell

  tell current session of newWindow
    delay 0.5
    set session3 to (split horizontally with profile "Default")
  end tell

  tell session2
    delay 0.5
    set session4 to (split horizontally with profile "MaterialDesignColors")
  end tell

  tell session3
    write text "cd $main_dir"
    write text "clear"
    write text "$console_cmd"
  end tell

  tell session4
    write text "cd $main_dir"
    write text "clear"
  end tell
end tell

delay 0.5
tell application "System Events"
  key code 123 using {control down, option down}
end tell
EOF
}