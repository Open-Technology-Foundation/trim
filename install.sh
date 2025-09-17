#!/usr/bin/env bash
#
# Install script for Bash String Trim Utilities
#
# This script installs the trim utilities to the system:
# 1. Copies the script files to the installation directory (default: /usr/share/trim)
# 2. Creates symlinks in the bin directory (default: /usr/local/bin)
# 3. Makes all scripts executable

set -euo pipefail

# Default installation directories
INSTALL_DIR="/usr/share/trim"
SYMLINK_DIR="/usr/local/bin"

# Script files to install
SCRIPTS=("trim.bash" "ltrim.bash" "rtrim.bash" "trimv.bash" "trimall.bash")

# Display help message
show_help() {
  cat << EOF
Install Bash String Trim Utilities

Usage: 
  ./install.sh [options]
  sudo ./install.sh [options]

Options:
  -h, --help            Show this help message
  -d, --dir DIR         Set installation directory (default: $INSTALL_DIR)
  -s, --symlink DIR     Set symlink directory (default: $SYMLINK_DIR)
  --no-symlinks         Don't create symlinks
  --uninstall           Remove previously installed files and symlinks

Example:
  sudo ./install.sh                   # Standard installation
  sudo ./install.sh --dir /opt/trim   # Install to custom directory
  sudo ./install.sh --uninstall       # Remove installation

EOF
  exit 0
}

# Parse command line arguments
NO_SYMLINKS=0
UNINSTALL=0

while (($#)); do
  case $1 in
    -h|--help)
      show_help
      ;;
    -d|--dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    -s|--symlink)
      SYMLINK_DIR="$2"
      shift 2
      ;;
    --no-symlinks)
      NO_SYMLINKS=1
      shift
      ;;
    --uninstall)
      UNINSTALL=1
      shift
      ;;
    *)
      >&2 echo "Error: Unknown option: $1"
      >&2 show_help
      ;;
  esac
done

# Check if running as root (needed for system dirs)
check_root() {
  ((EUID)) && {
    >&2 echo "Error: This script must be run as root to install to system directories."
    >&2 echo "$(basename -- "$0") --help"
    exit 1
  }
  return 0
}

# Uninstall function
uninstall() {
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
  
  # Remove installation directory
  if [[ -d "$INSTALL_DIR" ]]; then
    echo "Removing directory: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi
  
  echo "Uninstall complete!"
  exit 0
}

# Main installation function
install() {
  # Create installation directory if it doesn't exist
  if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
  fi
  
  # Copy files to installation directory
  echo "Installing trim utilities to $INSTALL_DIR..."
  for script in "${SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
      echo "Installing: $script"
      cp "$script" "$INSTALL_DIR/"
      chmod +x "$INSTALL_DIR/$script"
    else
      >&2 echo "Warning: Script not found: $script"
    fi
  done
  
  # Create trim.inc.sh (all modules in one)
  ( echo '#!/usr/bin/env bash'
    declare -a Files=()
    declare -- file
    readarray -r Files < <(find "$INSTALL_DIR" -type f -name '*.bash')
    for file in "${Files[@]}"; do echo "source -- '$file'"; done
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

# Check if running as root for standard system paths
if [[ "$INSTALL_DIR" == "/usr/share/trim" || "$SYMLINK_DIR" == "/usr/local/bin" ]]; then
  check_root
fi

# Uninstall if requested
if [[ $UNINSTALL -eq 1 ]]; then
  uninstall
fi

# Perform installation
install

#fin
