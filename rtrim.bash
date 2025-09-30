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
  fi

  # Process stdin if available
  if [[ ! -t 0 ]]; then
    local -- REPLY
    while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
      # Remove trailing whitespace
      REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
      echo "$REPLY"
    done
  fi
}
declare -fx rtrim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  # Check for help flag in $1 or $2 (after -e)
  [[ "${1:-}" =~ ^(-h|--help)$ ]] || [[ "${2:-}" =~ ^(-h|--help)$ ]] && {
    cat <<'EOT'
Usage: rtrim [-e] string    # Remove trailing whitespace
       rtrim < file         # Process stdin stream

Options:
  -e          Process escape sequences in the input string
  -h, --help  Display this help message
EOT
    exit 0
  }

  # Validate flags
  if [[ "${1:-}" == -* && ! "${1:-}" =~ ^-e$ ]]; then
    >&2 echo "Error: Unknown option '$1'"
    >&2 echo "Try 'rtrim --help' for more information."
    exit 22
  fi

  rtrim "$@"
fi

#fin
