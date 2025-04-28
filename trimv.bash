#!/usr/bin/env bash
# Module: trimv
#
# Removes whitespace and assigns result to a variable
#
# Usage:
#   trimv -n varname string  # Assign trimmed string to varname
#   trimv string             # Output trimmed string to stdout
#   trimv < file             # Process stdin stream
#
# Options:
#   -n varname  Variable to store result (defaults to TRIM)
#
# Examples:
#   trimv -n result "  hello world  "
#   echo "$result"  # Outputs: "hello world"
#
# Note: When storing multiline input, literal '\n' is added
#
# See also: trim, ltrim, rtrim, trimall
trimv() {
  # Check for -n flag to specify a variable name
  if (($#)); then
    if [[ $1 == '-n' ]]; then
      # Create a global variable for default fallback
      local -g TRIM
      # Set up name reference to target variable, defaulting to TRIM
      declare -n Var=${2:-TRIM}
      # Remove processed arguments
      shift 2
    fi
  fi

  # Process command-line arguments if present
  if (($#)); then
    local -- v="$*"
    # Remove leading whitespace
    v="${v#"${v%%[![:blank:]]*}"}"

    if [[ -R Var ]]; then
      # Assign to the target variable if using -n
      Var="${v%"${v##*[![:blank:]]}"}"
    else
      # Otherwise print to stdout
      echo -n "${v%"${v##*[![:blank:]]}"}"
    fi
  else
    # Process stdin if no arguments
    local -- REPLY
    while read -r; do
      # Remove leading whitespace
      REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"

      if [[ -R Var ]]; then
        # Append to the target variable with newline if using -n
        Var+="${REPLY%"${REPLY##*[![:blank:]]}"}\n"
      else
        # Otherwise print to stdout
        echo -n "${REPLY%"${REPLY##*[![:blank:]]}"}"
      fi
    done
  fi
}
declare -fx trimv

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Execute when run directly
  trimv "$@"
fi

#fin
