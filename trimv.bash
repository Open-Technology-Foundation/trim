#!/usr/bin/env bash
# Module: trimv
#
# Removes whitespace and assigns result to a variable
#
# Usage:
#   trimv [-e] [-n varname] string  # Assign trimmed string to varname
#   trimv string                    # Output trimmed string to stdout
#   trimv < file                    # Process stdin stream
#
# Options:
#   -e          Process escape sequences in the input string
#   -n varname  Variable to store result (defaults to TRIM)
#
# Examples:
#   trimv -n result "  hello world  "
#   echo "$result"  # Outputs: "hello world"
#
# See also: trim, ltrim, rtrim, trimall
trimv() {
  local process_escape=false
  local varname=""
  
  # Process command line options
  if (($#)); then
    # Check for -e flag to process escape sequences
    if [[ $1 == '-e' ]]; then
      process_escape=true
      shift
    fi
    
    # Check for -n flag to specify a variable name
    if [[ $1 == '-n' ]]; then
      # Get variable name, default to TRIM
      varname="${2:-TRIM}"
      
      # Validate variable name
      if ! [[ $varname =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Error: Invalid variable name '$varname'" >&2
        return 1
      fi
      
      # Export to parent environment
      export _TRIMV_VARNAME="$varname"
      # Create variable if it doesn't exist
      [[ -z "${!varname+x}" ]] && eval "$varname=''"
      
      # Remove processed arguments
      shift 2
    fi
  fi

  # Process command-line arguments if present
  if (($#)); then
    local -- v
    
    # Process escape sequences if -e flag was used
    if [[ $process_escape == true ]]; then
      v="$(echo -en "$*")"
    else
      v="$*"
    fi
    
    # Remove leading whitespace using parameter expansion
    v="${v#"${v%%[![:blank:]]*}"}"
    # Remove trailing whitespace
    v="${v%"${v##*[![:blank:]]}"}"

    if [[ -n "$varname" ]]; then
      # Assign to the target variable if using -n
      eval "$varname=\"\$v\""
    else
      # Otherwise print to stdout
      echo -n "$v"
    fi
  else
    # Process stdin if no arguments
    if [[ -n "$varname" ]]; then
      # Process input and write to temporary file
      local tmp_file
      tmp_file=$(mktemp)
      
      # Read line by line, trim, and save to temp file
      local REPLY
      while read -r; do
        # Remove leading whitespace
        REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
        # Remove trailing whitespace
        echo "${REPLY%"${REPLY##*[![:blank:]]}"}" >> "$tmp_file"
      done
      
      # Read the processed content into the variable
      if [[ -s "$tmp_file" ]]; then
        # Use cat to avoid potential problems with special characters
        local content
        content=$(<"$tmp_file")
        # Set the variable using eval
        eval "$varname=\"\$content\""
      else
        # Empty file, set to empty string
        eval "$varname=''"
      fi
      
      # Clean up
      rm -f "$tmp_file"
    else
      # Process line by line for stdout
      local -- REPLY
      while read -r; do
        # Remove leading whitespace
        REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
        # Remove trailing whitespace
        echo -n "${REPLY%"${REPLY##*[![:blank:]]}"}"
      done
    fi
  fi
}
declare -fx trimv

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]] && {
    echo "Usage: trimv [-e] [-n varname] string    # Assign trimmed string to varname"
    echo "       trimv string              # Output trimmed string to stdout"
    echo "       trimv < file              # Process stdin stream"
    echo ""
    echo "Options:"
    echo "  -e          Process escape sequences in the input string"
    echo "  -n varname  Variable to store result (defaults to TRIM)"
    echo "  -h, --help  Display this help message"
    exit 0
  }

  trimv "$@"
fi

#fin