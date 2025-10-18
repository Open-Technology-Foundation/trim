#!/usr/bin/env bash
# Removes trailing whitespace from strings or input streams

rtrim() {
  # Process arguments if provided
  if (($#)); then
    local -- v
    if [[ $1 == '-e' ]]; then
      # Process escape sequences when -e flag is used
      shift
      v=$(echo -en "$*")
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
  return 0
}
declare -fx rtrim

# Check if the script is being sourced or executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] || return 0
#!/bin/bash #semantic -------------------------------------------------------
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- VERSION='1.0.0' SCRIPT_NAME=rtrim.bash

if (($#)); then
  case $1 in
    -h|--help)
        cat <<EOT
$SCRIPT_NAME $VERSION - Remove trailing blanks chars from string

Usage: rtrim [-e] string    # Remove trailing whitespace
       rtrim < file         # Process stdin stream

Options:
    -e            Process escape sequences in the input string
    -V, --version Display "$SCRIPT_NAME $VERSION"
    -h, --help    Display this help message

Examples:
  str="   hello world   "
  str=\$(rtrim "\$str")       # Result: "   hello world"
  echo "  text  " | rtrim   # Output: "  text"

See also: trim, ltrim, trimv, trimall
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

rtrim "$@"
#fin
