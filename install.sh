#!/usr/bin/env bash
# Install script for Bash String Trim Utilities

set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='0.9.5.420'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Default installation directories
declare -- INSTALL_DIR=/usr/share/yatti/trim
declare -- SYMLINK_DIR=/usr/local/bin

# Script files to install
declare -a SCRIPTS=(trim.bash ltrim.bash rtrim.bash trimv.bash trimall.bash squeeze.bash)

# Runtime flags
declare -i NO_SYMLINKS=0
declare -i UNINSTALL=0

# Display help message
show_help() {
  cat << EOF
Install Bash String Trim Utilities

Usage: 
  ./install.sh [options]
  sudo ./install.sh [options]

Options:
  -d, --dir DIR         Set installation directory (default: $INSTALL_DIR)
  -s, --symlink DIR     Set symlink directory (default: $SYMLINK_DIR)
  --no-symlinks         Don't create symlinks
  --uninstall           Remove previously installed files and symlinks
  -h, --help            Show this help message
  -V, --version         Show version information

Example:
  sudo ./install.sh                   # Standard installation
  sudo ./install.sh --dir /opt/trim   # Install to custom directory
  sudo ./install.sh --uninstall       # Remove installation

EOF
}

# Check if running as root (needed for system dirs)
check_root() {
  #shellcheck disable=SC2015
  ((EUID)) && {
    >&2 echo "Error: This script must be run as root to install to system directories."
    >&2 echo "$SCRIPT_NAME --help"
    exit 1
  } ||:
  return 0
}

# Uninstall function
uninstall() {
  local -- script base_name symlink

  echo "Uninstalling trim utilities..."

  # Remove symlinks
  for script in "${SCRIPTS[@]}"; do
    base_name="${script%.bash}"
    symlink="$SYMLINK_DIR/$base_name"
    if [[ -L "$symlink" ]]; then
      echo "Removing symlink: $symlink"
      rm -f "$symlink"
    fi
  done
  
  # Remove installation directory (only the trim subdirectory, preserving parent /usr/share/yatti)
  if [[ -d "$INSTALL_DIR" ]]; then
    echo "Removing directory: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi
  
  echo "Uninstall complete!"
}

# Main installation function
install() {
  local -- script base_name symlink

  # Create installation directory if it doesn't exist
  if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
  fi
  
  # Copy files to installation directory
  echo "Installing trim utilities to $INSTALL_DIR..."
  for script in "${SCRIPTS[@]}"; do
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
      echo "Installing: $script"
      cp "$SCRIPT_DIR/$script" "$INSTALL_DIR/"
      chmod +x "$INSTALL_DIR/$script"
    else
      >&2 echo "Warning: Script not found: $script"
    fi
  done
  
  # Create trim.inc.sh (all modules in one)
  ( echo '#!/bin/bash'
    echo "# Bash String Trim Utilities - Combined Module File"
    echo "#"
    echo "# This file combines all trim utility functions into a single file"
    echo "# for easy sourcing. Source this file to load all trim functions:"
    echo "#   source $INSTALL_DIR/trim.inc.sh"
    echo "#"
    echo "# Available functions: trim, ltrim, rtrim, trimv, trimall, squeeze"
    echo
    echo
    local -a Files=()
    local -- file
    readarray -t Files < <(find "$INSTALL_DIR" -maxdepth 1 -type f -name '*.bash')
    for file in "${Files[@]}"; do
      #shellcheck disable=SC1090
      source -- "$file"
      declare -pf "$(basename -s .bash -- "$file")"
      echo
    done
    echo '#fin'
  ) >"$INSTALL_DIR"/trim.inc.sh

  # Create symlinks if requested
  if [[ $NO_SYMLINKS -eq 0 ]]; then
    echo "Creating symlinks in $SYMLINK_DIR..."
    
    # Create symlink directory if it doesn't exist
    if [[ ! -d "$SYMLINK_DIR" ]]; then
      mkdir -p "$SYMLINK_DIR"
    fi
    
    for script in "${SCRIPTS[@]}"; do
      base_name="${script%.bash}"
      symlink="$SYMLINK_DIR/$base_name"
      
      echo "Creating symlink: $symlink -> $INSTALL_DIR/$script"
      ln -sf "$INSTALL_DIR/$script" "$symlink"
    done
  fi
  
  echo "Installation complete!"
}

# Main entry point
main() {
  # Parse command line arguments
  while (($#)); do
    case $1 in
    -h|--help)
      show_help
      return 0
      ;;
    -V|--version)
      echo "$SCRIPT_NAME $VERSION"
      return 0
      ;;
    -d|--dir)
      INSTALL_DIR=$2
      shift
      ;;
    -s|--symlink)
      SYMLINK_DIR=$2
      shift
      ;;
    --no-symlinks)
      NO_SYMLINKS=1
      ;;
    --uninstall)
      UNINSTALL=1
      ;;
    *)
      >&2 echo "Error: Unknown option ${1@Q}. Try: $SCRIPT_NAME --help"
      exit 22
      ;;
    esac
    shift
  done

  # Check if running as root for standard system paths
  if [[ "$INSTALL_DIR" == /usr/share/yatti/trim || "$SYMLINK_DIR" == /usr/local/bin ]]; then
    check_root
  fi

  # Uninstall if requested
  if ((UNINSTALL)); then
    uninstall
    return 0
  fi

  # Perform installation
  install
}

main "$@"

#fin
