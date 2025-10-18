#!/usr/bin/env bash
# Module: trimv
#
# Removes leading and trailing whitespace and assigns result to a variable.
# Can also output trimmed result to stdout if no variable name is specified.
#
# Usage:
#   trimv [-e] [-n varname] string  # Assign trimmed string to varname
#   trimv string                    # Output trimmed string to stdout
#   trimv < file                    # Process stdin stream
#
# Options:
#   -e          Process escape sequences in the input string
#   -n varname  Variable to store result (defaults to TRIM)
#   -h, --help  Display help message
#
# Examples:
#   trimv -n result "  hello world  "  # Assigns trimmed result to $result
#   echo "$result"                     # Outputs: "hello world"
#   
#   trimv -e -n content "\t hello \n"  # Process escape sequences and store in $content
#   cat file.txt | trimv -n data       # Read from file, trim, store in $data
#
# See also: trim, ltrim, rtrim, trimall
trimv() {
  local -i process_escape=0
  local -- varname=""
  
  # Process command line options
  if (($#)); then
    # Check for -e flag to process escape sequences
    if [[ $1 == '-e' ]]; then
      process_escape=1
      shift
    fi
    
    # Check for -n flag to specify a variable name
    if [[ ${1:-} == '-n' ]]; then
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
      [[ -n "${!varname+x}" ]] || eval "$varname=''"
      
      # Remove processed arguments
      shift 2
    fi
  fi

  # Process command-line arguments if present
  if (($#)); then
    local -- v
    
    # Process escape sequences if -e flag was used
    if ((process_escape)); then
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
    return 0
  fi

  # Process stdin if no arguments
  if [[ ! -t 0 ]]; then
    if [[ -n "$varname" ]]; then
      # Create secure temporary file with appropriate permissions
      local -- tmp_file
      tmp_file=$(mktemp -t "trimv_XXXXXXXXXX")
      chmod 600 "$tmp_file"

      # Process input line by line, applying trim operation
      local -- REPLY
      while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
        # Remove leading and trailing whitespace
        REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
        REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
        echo "$REPLY" >> "$tmp_file"
      done

      # Set variable content from file
      if [[ -s "$tmp_file" ]]; then
        local -- content
        content=$(<"$tmp_file")
        eval "$varname=\"\$content\""
      else
        eval "$varname=''"
      fi

      # Clean up temporary file securely
      rm -f "$tmp_file" 2>/dev/null || true
    else
      # Process line by line for stdout
      local -- REPLY
      while IFS= read -r REPLY || [[ -n "$REPLY" ]]; do
        # Remove leading and trailing whitespace
        REPLY="${REPLY#"${REPLY%%[![:blank:]]*}"}"
        REPLY="${REPLY%"${REPLY##*[![:blank:]]}"}"
        echo "$REPLY"
      done
    fi
  fi
}
declare -fx trimv

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cat <<'EOT'
trimv - Remove leading and trailing whitespace and assign to a variable

Usage:
  source /usr/share/yatti/trim/trimv.bash
  trimv [-e] [-n varname] string

Options:
  -e          Process escape sequences in the input string
  -n varname  Variable to store result (defaults to TRIM)
  -h, --help  Display this help message

Examples:
  source /usr/share/yatti/trim/trimv.bash
  trimv -n RESULT "  hello world  "
  echo "$RESULT"                        # Outputs: hello world

  trimv -e -n CONTENT "\t hello \n"     # Process escape sequences
  cat file.txt | trimv -n DATA          # Read from stdin

Note:
  This utility MUST be sourced to use the -n variable assignment feature.
  When run as a script, variable assignments only affect the subprocess and
  are not visible in the parent shell.

  To use trimv, source it first:
    source /usr/share/yatti/trim/trimv.bash

  Or source all utilities at once:
    source /usr/share/yatti/trim/trim.inc.sh

See also: trim, ltrim, rtrim, trimall, squeeze
EOT
  exit 0
fi

#fin
