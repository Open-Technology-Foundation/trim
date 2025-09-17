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

### Everyday Programming Scenarios

```bash
# Parse and clean JSON or YAML config values
CONFIG_VALUE=$(grep "^[[:space:]]*api_key:" config.yml | cut -d':' -f2 | trim)
echo "Using API key: $CONFIG_VALUE"

# Standardize CSV data import
while IFS=, read -r id name email; do
  # Clean each field properly - note the variable assignment
  trimv -n ID "$id"
  trimv -n NAME "$name"
  trimv -n EMAIL "$email"
  
  echo "Processing user: $ID -> $NAME ($EMAIL)"
done < users.csv

# Normalize command output for parsing
disk_usage=$(df -h | grep "/$" | awk '{print $5}' | trim)
if [[ "${disk_usage%\%}" -gt 90 ]]; then
  echo "Warning: Disk usage is $disk_usage"
fi
```

### Advanced Variable Management with trimv

```bash
# Cleaner variable assignment without nested subshells
trimv -n API_RESPONSE "$(curl -s https://api.example.com/status)"

# Store multiline output with proper whitespace handling
trimv -n SQL_QUERY "
    SELECT 
        user_id, 
        first_name,
        last_name 
    FROM users 
    WHERE status = 'active'
"
echo "Running query: $SQL_QUERY"

# Clean up values from environment variables with escape sequences
trimv -e -n PATH_CLEAN "$PATH_WITH_ESCAPES"

# Create normalized environment variables for a process
export APP_ARGS=$(trimall "$USER_PROVIDED_ARGS")
```

### Data Processing and Validation

```bash
# Extract and validate configuration properties
prop_pattern="^[[:space:]]*[a-zA-Z0-9._-]+"
while IFS= read -r line; do
  # Skip comments and empty lines
  [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
  
  # Extract property name (keep only leading whitespace)
  prop_name=$(echo "$line" | grep -o "$prop_pattern" | rtrim)
  # Extract property value (remove all excess whitespace)
  prop_value=$(echo "$line" | sed "s/$prop_pattern[[:space:]]*=[[:space:]]*//" | trim)
  
  echo "Property: '$prop_name' = '$prop_value'"
done < application.properties

# Clean up and normalize data for comparison
if [[ "$(trimall < file1.log)" == "$(trimall < file2.log)" ]]; then
  echo "Log contents match when normalized"
fi
```

### Shell Script Development

```bash
# Source the trim utilities for use as functions
source /usr/share/trim/trim.bash
source /usr/share/trim/trimv.bash

# Define a clean logging function
log_message() {
  local level="$1"
  shift
  local message="$*"
  
  # Create a properly formatted timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Ensure consistent formatting regardless of input whitespace
  echo "[$timestamp] ${level^^}: $(trim "$message")"
}

log_message "info" "  Starting application...  "

# Parse command output safely
get_container_id() {
  local name="$1"
  local container_id
  
  # Use trimv to safely capture and clean the command output
  trimv -n container_id "$(docker ps --format '{{.ID}}' --filter "name=$name" 2>/dev/null)"
  
  if [[ -z "$container_id" ]]; then
    echo "No container found with name: $name" >&2
    return 1
  fi
  
  echo "$container_id"
}
```

### Processing Special Formats

```bash
# Parse and normalize tab-delimited data
cat data.tsv | while IFS=$'\t' read -r field1 field2 field3; do
  # Handle fields that may contain escape sequences
  trimv -e -n f1 "$field1"
  trimv -e -n f2 "$field2"
  trimv -e -n f3 "$field3"
  
  printf "%-20s | %-30s | %s\n" "$f1" "$f2" "$f3"
done

# Clean up multiline code snippets for documentation
code_block=$(cat <<EOF
    function example() {
        // This is sample code
        const result = process(input);
        return result;
    }
EOF
)
trimv -n clean_code "$code_block"
echo "```javascript"
echo "$clean_code"
echo "```"
```

### DevOps and System Administration

```bash
# Clean up output from system commands for logging
system_info=$(uname -a | trim)
echo "System: $system_info" >> system_report.log

# Process output from multiple commands with standardized whitespace
{
  echo "=== SYSTEM REPORT ==="
  echo "Hostname: $(hostname | trim)"
  echo "Kernel: $(uname -r | trim)"
  echo "Uptime: $(uptime | trimall)"
  echo "Memory:"
  free -h | while IFS= read -r line; do
    echo "  $(trim "$line")"
  done
} > system_report.txt

# Extract and verify configuration settings
verify_config() {
  local config_file="$1"
  local required_settings=("host" "port" "user" "timeout")
  local missing=()
  
  for setting in "${required_settings[@]}"; do
    value=$(grep "^[[:space:]]*$setting[[:space:]]*=" "$config_file" | cut -d'=' -f2 | trim)
    if [[ -z "$value" ]]; then
      missing+=("$setting")
    fi
  done
  
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Error: Missing required settings: ${missing[*]}"
    return 1
  fi
  
  return 0
}
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