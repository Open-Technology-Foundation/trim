#!/usr/bin/env bash
# Module: trim
#
# Removes leading and trailing whitespace from strings or input streams
#
# Usage: 
#   trim [-e] string    # Process command-line argument
#   trim < file         # Process stdin stream
#
# Options:
#   -e  Process escape sequences in the input string
#
# Examples:
#   str=" 123 "
#   str=$(trim "$str")  # Result: "123"
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
    while read -r; do
      # Remove leading whitespace
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
      # Remove trailing whitespace
      echo "${REPLY%"${REPLY##*[![:blank:]]}"}"
    done
  fi
}
declare -fx trim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Execute when run directly
  trim "$@"
fi

#fin
