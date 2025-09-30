#!/usr/bin/env bash
# Module: trimall
#
# Normalizes whitespace by removing leading/trailing whitespace and collapsing multiple spaces 
# to single spaces between words.
#
# Usage: 
#   trimall [-e] string    # Process command-line argument
#   trimall < file         # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#   -h, --help  Display help message
#
# Examples:
#   str="  multiple    spaces   here  "
#   str=$(trimall "$str")  # Result: "multiple spaces here"
#   
#   echo "  line1\n  line2  " | trimall  # Output: "line1 line2"
#
# See also: trim, ltrim, rtrim, trimv
# Disable shellcheck warnings for word splitting (which is intentional here)
#shellcheck disable=SC2048,SC2086
trimall() {
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

    # Use Bash's word splitting to normalize whitespace
    set -f  # Disable globbing
    set -- $v  # Word splitting collapses whitespace between arguments
    echo -n "$*"  # Output with single spaces between words
    set +f  # Restore globbing
    return 0
  fi

  # Process stdin if no arguments provided
  if [[ ! -t 0 ]]; then
    # Read all input into a variable
    local -- content=""
    local -- line
    
    # Process each line from stdin
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Add each line to content with a space
      [[ -n "$content" ]] && content+=" "
      content+="$line"
    done
    
    # If we have content, normalize it
    if [[ -n "$content" ]]; then
      # Disable globbing
      set -f
      # Process with word splitting to normalize spaces
      set -- $content
      # Output result without trailing newline
      echo -n "$*"
      # Restore globbing
      set +f
    fi
  fi
}
declare -fx trimall

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail

  # Check for help flag in $1 or $2 (after -e)
  [[ "${1:-}" =~ ^(-h|--help)$ ]] || [[ "${2:-}" =~ ^(-h|--help)$ ]] && {
    cat <<'EOT'
Usage: trimall [-e] string    # Normalize whitespace in string
       trimall < file         # Process stdin stream

Returns: String with normalized whitespace (single spaces between words)

Options:
  -e          Process escape sequences in the input string
  -h, --help  Display this help message
EOT
    exit 0
  }

  # Validate flags
  if [[ "${1:-}" == -* && ! "${1:-}" =~ ^-e$ ]]; then
    >&2 echo "Error: Unknown option '$1'"
    >&2 echo "Try 'trimall --help' for more information."
    exit 22
  fi

  trimall "$@"
fi

#fin
