#!/usr/bin/env bash
# Module: ltrim
#
# Removes leading whitespace from strings or input streams.
#
# Usage:
#   ltrim [-e] string   # Process command-line argument
#   ltrim < file        # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#   -h, --help  Display help message
#
# Examples:
#   str="   hello world   "
#   str=$(ltrim "$str")  # Result: "hello world   "
#   echo "  text  " | ltrim  # Output: "text  "
#
# See also: trim, rtrim, trimv, trimall
ltrim() {
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
    # Remove leading whitespace using parameter expansion
    echo -n "${v#"${v%%[![:blank:]]*}"}"
    return 0
  else
    # Process stdin if available
    local REPLY
    while IFS= read -r; do
      # Remove leading whitespace for each line
      echo -n "${REPLY#"${REPLY%%[![:blank:]]*}"}"
      echo
    done
  fi
}
declare -fx ltrim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]] && {
    echo "Usage: ltrim [-e] string    # Remove leading whitespace"
    echo "       ltrim < file         # Process stdin stream"
    echo ""
    echo "Options:"
    echo "  -e          Process escape sequences in the input string"
    echo "  -h, --help  Display this help message"
    exit 0
  }

  ltrim "$@"
fi

#fin
