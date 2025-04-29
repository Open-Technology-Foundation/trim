#!/usr/bin/env bash
# Module: rtrim
#
# Removes trailing whitespace from strings or input streams.
#
# Usage:
#   rtrim [-e] string   # Process command-line argument
#   rtrim < file        # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#   -h, --help  Display help message
#
# Examples:
#   str="   hello world   "
#   str=$(rtrim "$str")  # Result: "   hello world"
#   echo "  text  " | rtrim  # Output: "  text"
#
# See also: trim, ltrim, trimv, trimall
rtrim() {
  # Process arguments if provided
  if (($#)); then
    local -- v
    if [[ $1 == '-e' ]]; then
      # Process escape sequences when -e flag is used
      shift
      v="$(echo -en "$*")"
    else
      v="$*"
    fi
    # Remove trailing whitespace using parameter expansion
    echo -n "${v%"${v##*[![:blank:]]}"}"
    return 0
  else
    # Process stdin if available
    local REPLY
    while IFS= read -r; do
      # Remove trailing whitespace for each line
      echo -n "${REPLY%"${REPLY##*[![:blank:]]}"}"
      echo
    done
  fi
}
declare -fx rtrim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]] && {
    echo "Usage: rtrim [-e] string    # Remove trailing whitespace"
    echo "       rtrim < file         # Process stdin stream"
    echo ""
    echo "Options:"
    echo "  -e          Process escape sequences in the input string"
    echo "  -h, --help  Display this help message"
    exit 0
  }

  rtrim "$@"
fi

#fin
