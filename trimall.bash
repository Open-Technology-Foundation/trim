#!/usr/bin/env bash
# Module: trimall
#
# Normalizes whitespace by removing leading/trailing whitespace and collapsing internal spaces
#
# Usage: trimall string
#
# Returns: String with normalized whitespace (single spaces between words)
#
# Examples:
#   str="  multiple    spaces   here  "
#   str=$(trimall "$str")  # Result: "multiple spaces here"
#
# Note: Currently only processes command-line arguments (not stdin)
#
# See also: trim, ltrim, rtrim, trimv
# Disable shellcheck warnings for word splitting (which is intentional here)
#shellcheck disable=SC2048,SC2086
trimall() {
  # Normalizes whitespace by removing leading/trailing whitespace and collapsing multiple spaces
  # Disable globbing to prevent expansion of wildcards in input
  set -f
  # Word splitting is intentional here - Bash's word splitting naturally
  # collapses all whitespace between arguments into single spaces
  set -- $*
  # Output the arguments with single spaces between words
  printf '%s\n' "$*"
  # Restore globbing
  set +f
}
declare -fx trimall

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]] && {
    echo "Usage: trimall string    # Normalize whitespace in string"
    echo ""
    echo "Returns: String with normalized whitespace (single spaces between words)"
    echo ""
    echo "Options:"
    echo "  -h, --help  Display this help message"
    echo ""
    echo "Note: Currently only processes command-line arguments (not stdin)"
    exit 0
  }

  trimall "$@"
fi

#fin
