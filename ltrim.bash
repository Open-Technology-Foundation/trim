#!/usr/bin/env bash
# Module: ltrim
#
# Removes leading whitespace from strings or input streams
#
# Usage:
#   ltrim string        # Process command-line argument
#   ltrim < file        # Process stdin stream
#
# Examples:
#   str="   hello"
#   str=$(ltrim "$str")  # Result: "hello"
#
# See also: trim, rtrim, trimv, trimall
ltrim() {
  # Process arguments if provided
  if (($#)); then
    local v="$*"
    # Remove leading whitespace using parameter expansion
    echo "${v#"${v%%[![:blank:]]*}"}"
  else
    # Process stdin if available
    local REPLY
    while IFS= read -r; do
      # Remove leading whitespace for each line
      echo "${REPLY#"${REPLY%%[![:blank:]]*}"}"
    done
  fi
}
declare -fx ltrim

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Execute when run directly
  ltrim "$@"
fi

#fin
