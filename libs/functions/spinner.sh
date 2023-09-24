#!/bin/bash

# Spinner function
# Usage: spinner "command"
# Example: spinner "sleep 10"
# Source:
# https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-working-indicator

function cursorBack() {
  echo -en "\033[$1D"
}

spinner() {
  local PID=$!

  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  local charwidth=1

  echo -n ' '
  local i=0
  tput civis
  while [ -d /proc/$PID ]
  do
    local i=$(((i + $charwidth) % ${#spin}))
    printf "%s" "${spin:$i:$charwidth}"
    cursorBack $charwidth
    sleep .1
  done
  tput cnorm
}


