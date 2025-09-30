#!/usr/bin/env bash
# Module: trim
#
# Removes leading and trailing whitespace from strings or input streams.
#
# Usage: 
#   trim [-e] string    # Process command-line argument
#   trim < file         # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#   -h, --help  Display help message
#
# Examples:
#   str="  hello world  "
#   str=$(trim "$str")  # Result: "hello world"
#   echo "  text  " | trim  # Output: "text"
#
# See also: ltrim, rtrim, trimv, trimall
trim() {
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
    # Remove leading whitespace first
    v="${v#"${v%%[![:blank:]]*}"}"
    # Then remove trailing whitespace
    echo -n "${v%"${v##*[![:blank:]]}"}"
    return 0
  fi

  # Process stdin if available
  if [[ ! -t 0 ]]; then
    local -- REPLY
    while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
      # Remove leading whitespace
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
      # Remove trailing whitespace
      REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
      echo "$REPLY"
    done
  fi
}
declare -fx trim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  # Check for help flag in $1 or $2 (after -e)
  [[ "${1:-}" =~ ^(-h|--help)$ ]] || [[ "${2:-}" =~ ^(-h|--help)$ ]] && {
    cat <<'EOT'
Usage: trim [-e] string    # Remove leading and trailing whitespace
       trim < file         # Process stdin stream

Options:
  -e          Process escape sequences in the input string
  -h, --help  Display this help message
EOT
    exit 0
  }

  # Validate flags
  if [[ "${1:-}" == -* && ! "${1:-}" =~ ^-e$ ]]; then
    >&2 echo "Error: Unknown option '$1'"
    >&2 echo "Try 'trim --help' for more information."
    exit 22
  fi

  trim "$@"
fi

#fin
