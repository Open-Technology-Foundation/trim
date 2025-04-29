# Bash String Trim Utilities

A collection of lightweight Bash utilities for managing whitespace in strings and streams.

## Overview

These utilities provide efficient text trimming operations using pure Bash parameter expansion, without external dependencies like sed or awk. Each utility can be used as a standalone command or sourced as a function in Bash scripts.

## Utilities

- **trim** - Removes both leading and trailing whitespace
- **ltrim** - Removes only leading whitespace
- **rtrim** - Removes only trailing whitespace
- **trimv** - Removes whitespace and assigns result to a variable
- **trimall** - Normalizes whitespace (removes leading/trailing spaces and collapses multiple spaces to single spaces)

## Basic Usage

```bash
# Basic string trimming
trim "  hello world  "       # Output: "hello world"
ltrim "  hello world  "      # Output: "hello world  "
rtrim "  hello world  "      # Output: "  hello world"

# Process file content
trim < input.txt > clean.txt
cat file.txt | ltrim > indentation_removed.txt

# Store results in variable
trimv -n result "  hello world  "
echo "$result"               # Output: "hello world"

# Normalize all whitespace
trimall "  multiple    spaces   here  "  # Output: "multiple spaces here"
```

## Command Options

| Utility | Options | Description |
|---------|---------|-------------|
| **trim** | `-e` | Process escape sequences (`\t`, `\n`, etc.) in the input |
| | `-h, --help` | Display help message |
| **ltrim** | `-e` | Process escape sequences in the input |
| | `-h, --help` | Display help message |
| **rtrim** | `-e` | Process escape sequences in the input |
| | `-h, --help` | Display help message |
| **trimv** | `-e` | Process escape sequences |
| | `-n varname` | Name of variable to store result (defaults to `TRIM`) |
| | `-h, --help` | Display help message |
| **trimall** | `-e` | Process escape sequences |
| | `-h, --help` | Display help message |

## Key Features

- **Efficient Implementation** - Uses Bash parameter expansion with `[:blank:]` character class
- **No Dependencies** - Pure Bash implementation, no external tools required
- **Dual Usage** - Functions both as standalone commands and as sourceable functions
- **Handles Streams** - Process stdin/stdout for pipeline integration
- **Escape Sequence Support** - Process backslash escape sequences with the `-e` flag
- **Variable Assignment** - Store results directly in variables with `trimv`

## Examples

### Processing User Input

```bash
# Clean user input before processing
read -p "Enter value: " input
clean_input=$(trim "$input")
echo "Processing: '$clean_input'"
```

### File Processing

```bash
# Remove indentation from config files but keep trailing spaces
while IFS= read -r line; do
  key_value=$(ltrim "$line")
  process_config_line "$key_value"
done < config.txt
```

### Handling Multiline Content

```bash
# Normalize multiline content for comparison
normalized1=$(cat file1.txt | trimall)
normalized2=$(cat file2.txt | trimall)

if [[ "$normalized1" == "$normalized2" ]]; then
  echo "Files match when normalized"
fi
```

### Processing Escape Sequences

```bash
# Handle tab-delimited data with escape sequences
data="Name\\tValue\\tDescription"
parsed_data=$(trim -e "$data")
echo "$parsed_data"  # Output: "Name	Value	Description"
```

### Using in Loops

```bash
# Process file names, removing whitespace
for file in *.txt; do
  name=$(basename "$file" .txt | trim)
  echo "Processing: $name"
done
```

### Advanced Pipeline Usage

```bash
# Extract and clean settings from config files
find . -name "*.conf" | xargs cat | grep "^[[:space:]]*setting" | ltrim | sort
```

## Installation

### Option 1: Using the Installation Script

```bash
git clone https://github.com/Open-Technology-Foundation/trim
cd trim
sudo ./install.sh
```

Installation options:

```bash
# Show help
./install.sh --help

# Install to custom directory
sudo ./install.sh --dir /opt/trim

# Install without symlinks
sudo ./install.sh --no-symlinks

# Uninstall
sudo ./install.sh --uninstall
```

### Option 2: Quick Installation

One-liner to install directly from GitHub:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Open-Technology-Foundation/trim/main/install.sh)"
```

### Option 3: Manual Installation

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/trim /usr/share/trim

# Make scripts executable
chmod +x /usr/share/trim/*.bash

# Create symlinks
ln -sf /usr/share/trim/trim.bash /usr/local/bin/trim
ln -sf /usr/share/trim/ltrim.bash /usr/local/bin/ltrim
ln -sf /usr/share/trim/rtrim.bash /usr/local/bin/rtrim
ln -sf /usr/share/trim/trimv.bash /usr/local/bin/trimv
ln -sf /usr/share/trim/trimall.bash /usr/local/bin/trimall
```

## Testing

The utilities include a comprehensive test suite:

```bash
# Run all tests
./test/run-tests.sh

# Run only unit tests
./test/run-tests.sh unit

# Run only integration tests
./test/run-tests.sh integration
```

## Limitations

- Requires Bash shell (not POSIX sh compatible)
- Uses Bash's `[:blank:]` character class which handles spaces and tabs but not all Unicode whitespace
- When using `trimv` for variable assignment, there are standard Bash subprocess limitations

## License

GNU General Public License v3.0 - See the LICENSE file for details.

## Repository

https://github.com/Open-Technology-Foundation/trim

#fin