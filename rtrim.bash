#!/usr/bin/env bash
# Module: rtrim
#
# Removes trailing whitespace from strings or input streams
#
# Usage:
#   rtrim string        # Process command-line argument
#   rtrim < file        # Process stdin stream
#
# Examples:
#   str="hello   "
#   str=$(rtrim "$str")  # Result: "hello"
#
# See also: trim, ltrim, trimv, trimall
rtrim() {
  # Process arguments if provided
  if (($#)); then
    local v="$*"
    # Remove trailing whitespace using parameter expansion
    echo "${v%"${v##*[![:blank:]]}"}"
  else
    # Process stdin if available
    local REPLY
    while IFS= read -r; do
      # Remove trailing whitespace for each line
      echo "${REPLY%"${REPLY##*[![:blank:]]}"}"
    done
  fi
}
declare -fx rtrim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]] && {
    echo "Usage: rtrim string    # Remove trailing whitespace"
    echo "       rtrim < file    # Process stdin stream"
    echo ""
    echo "Options:"
    echo "  -h, --help  Display this help message"
    exit 0
  }

  rtrim "$@"
fi

#fin
