#!/usr/bin/env bash
# Module: squeeze
#
# Squeezes consecutive blank characters (spaces and tabs) into single spaces.
# Preserves leading and trailing whitespace.
#
# Usage:
#   squeeze [-e] string   # Process command-line argument
#   squeeze < file        # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#   -h, --help  Display help message
#
# Examples:
#   str="hello    world"
#   str=$(squeeze "$str")  # Result: "hello world"
#   echo "  multiple    spaces  " | squeeze  # Output: "  multiple spaces  "
#
# See also: trim, ltrim, rtrim, trimall, trimv
squeeze() {
  local -- process_escape=false

  # Check for -e flag to process escape sequences
  if [[ "${1:-}" == '-e' ]]; then
    process_escape=true
    shift
  fi

  # Process arguments if provided
  if (($#)); then
    local -- v

    # Process escape sequences if -e flag was used
    if [[ $process_escape == true ]]; then
      v="$(echo -en "$*")"
    else
      v="$*"
    fi

    # Squeeze consecutive blanks using pure Bash
    # First convert tabs to spaces for uniform handling
    v="${v//$'\t'/ }"
    # Then squeeze multiple spaces to single space
    while [[ $v =~ "  " ]]; do
      v="${v//  / }"
    done
    echo -n "$v"
    return 0
  fi

  # Process stdin if no arguments provided
  if [[ ! -t 0 ]]; then
    local -- REPLY
    while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
      # Convert tabs to spaces
      REPLY="${REPLY//$'\t'/ }"
      # Squeeze multiple spaces
      while [[ $REPLY =~ "  " ]]; do
        REPLY="${REPLY//  / }"
      done
      echo "$REPLY"
    done
  fi
}
declare -fx squeeze

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  # Check for help flag in $1 or $2 (after -e)
  [[ "${1:-}" =~ ^(-h|--help)$ ]] || [[ "${2:-}" =~ ^(-h|--help)$ ]] && {
    cat <<'EOT'
Usage: squeeze [-e] string    # Squeeze consecutive blanks to single spaces
       squeeze < file         # Process stdin stream

Options:
  -e          Process escape sequences in the input string
  -h, --help  Display this help message
EOT
    exit 0
  }

  # Validate flags
  if [[ "${1:-}" == -* && ! "${1:-}" =~ ^-e$ ]]; then
    >&2 echo "Error: Unknown option '$1'"
    >&2 echo "Try 'squeeze --help' for more information."
    exit 22
  fi

  squeeze "$@"
fi

#fin