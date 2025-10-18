#!/usr/bin/env bash
# Squeezes consecutive blank characters (spaces and tabs) into single spaces, preserving leading and trailing whitespace

squeeze() {
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
    ((process_escape)) && v=$(echo -en "$*") || v="$*"

    # Squeeze consecutive blanks using pure Bash
    # First convert tabs to spaces for uniform handling
    v=${v//$'\t'/ }
    v=${v//   / }
    # Then squeeze multiple spaces to single space
    while [[ $v =~ '  ' ]]; do
      v=${v//  / }
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
      REPLY="${REPLY//   / }"
      # Squeeze multiple spaces
      while [[ $REPLY =~ '  ' ]]; do
        REPLY="${REPLY//  / }"
      done
      echo "$REPLY"
    done
  fi
}
declare -fx squeeze

# Check if the script is being sourced or executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0
#!/bin/bash #semantic -------------------------------------------------------
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- VERSION='1.0.0' SCRIPT_NAME=squeeze.bash

if (($#)); then
  case $1 in
    -h|--help)
        cat <<EOT
$SCRIPT_NAME $VERSION - Squeeze space from string.

Squeezes consecutive blank characters (spaces and tabs) into single spaces.
Preserves leading and trailing whitespace.

Usage: squeeze [-e] string   # Squeeze consecutive blanks to single space
       squeeze < file        # Process stdin stream

Options:
  -e             Render escape sequences in input string
  -V, --version  Display "$SCRIPT_NAME $VERSION"
  -h, --help     Display this help message

Examples:
  str="hello    world"
  str=\$(squeeze "\$str")     # Result: "hello world"
  echo "  multiple    spaces  " | squeeze  # Output: "  multiple spaces  "

See also: trim, ltrim, rtrim, trimall, trimv
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

squeeze "$@"
#fin
