#!/usr/bin/env bash
# Normalizes whitespace by removing leading/trailing whitespace and collapsing multiple spaces to single spaces
#shellcheck disable=SC2048,SC2086

trimall() {
  local -i process_escape=0

  # Check for -e flag to process escape sequences
  if [[ "${1:-}" == '-e' ]]; then
    process_escape=1
    shift
  fi

  # Process arguments if provided
  if (($#)); then
    local -- v

    # Process escape sequences if -e flag was used
    if ((process_escape)); then
      v=$(echo -en "$*")
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
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0
#!/bin/bash #semantic -------------------------------------------------------
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- VERSION='0.9.5.420' SCRIPT_NAME=trimall.bash

if (($#)); then
  case $1 in
    -h|--help)
        cat <<EOT
$SCRIPT_NAME $VERSION - Normalise whitespace in string

Usage: trimall [-e] string    # Normalize whitespace in string
       trimall < file         # Process stdin stream

Returns:
       String with normalized whitespace (single spaces between words)

Options:
    -e            Process escape sequences in the input string
    -V, --version Display "$SCRIPT_NAME $VERSION"
    -h, --help    Display this help message

Examples:
  str="  multiple    spaces   here  "
  str=\$(trimall "\$str")     # Result: "multiple spaces here"
  echo "  line1\n  line2  " | trimall  # Output: "line1 line2"

See also: trim, ltrim, rtrim, trimv
EOT
        exit 0
        ;;
    -V|--version)
        echo "$SCRIPT_NAME $VERSION"
        exit 0
        ;;
    -e) ;;

    -*) >&2 echo "$SCRIPT_NAME: ✗ Unknown option ${1@Q}"
        exit 22 ;;
  esac
fi

trimall "$@"
#fin
