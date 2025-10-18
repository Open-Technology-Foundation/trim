# Bash String Trim Utilities

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash 4+](https://img.shields.io/badge/bash-4%2B-green.svg)](https://www.gnu.org/software/bash/)

**Pure Bash string trimming utilities with zero dependencies** — Fast, portable, and battle-tested whitespace manipulation tools for shell scripts.

🔗 **Repository:** [github.com/Open-Technology-Foundation/trim](https://github.com/Open-Technology-Foundation/trim)

---

## Table of Contents

- [Quick Start](#quick-start)
- [Why Use Trim Utilities?](#why-use-trim-utilities)
- [Comparison with Alternatives](#comparison-with-alternatives)
- [Overview](#overview)
- [Utilities Reference](#utilities-reference)
- [Installation](#installation)
- [Basic Usage](#basic-usage)
  - [Command-Line Usage](#command-line-usage)
  - [Sourced Function Usage](#sourced-function-usage)
- [Command Options](#command-options)
- [Practical Examples](#practical-examples)
- [How It Works](#how-it-works)
- [Testing](#testing)
- [Performance](#performance)
- [Advanced Usage](#advanced-usage)
- [Limitations & Gotchas](#limitations--gotchas)
- [When NOT to Use](#when-not-to-use)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

```bash
# Install (requires sudo)
git clone https://github.com/Open-Technology-Foundation/trim
cd trim
sudo ./install.sh

# Basic usage
trim "  hello world  "              # Output: "hello world"
echo "  text  " | trim              # Output: "text"

# Store result in variable (must source first)
source /usr/share/yatti/trim/trimv.bash
trimv -n result "  hello  "
echo "$result"                      # Output: "hello"

# Normalize whitespace
trimall "  multiple    spaces  "    # Output: "multiple spaces"
```

See [full documentation](#basic-usage) below.

---

## Why Use Trim Utilities?

**Pure Bash Implementation**
- **Zero Dependencies** — No sed, awk, tr, or other external tools required
- **Fast** — Uses native Bash parameter expansion, no subprocess overhead
- **Portable** — Works anywhere Bash 4+ is available

**Flexible Architecture**
- **Dual-Mode** — Use as command-line tools OR source as functions in scripts
- **Pipeline-Friendly** — Full stdin/stdout support for Unix pipelines
- **Variable Assignment** — Direct assignment with `trimv` (no subshells needed)

**Production-Ready**
- **Well-Tested** — 90+ test assertions across 10 comprehensive test suites
- **Battle-Tested** — ~600 lines of code, proven in real-world scenarios
- **KISS Principle** — Simple, focused utilities that do one thing well

---

## Comparison with Alternatives

| Feature                | trim utils | sed/awk | tr      | Python |
|------------------------|-----------|---------|---------|--------|
| No dependencies        | ✓         | ✗       | ✗       | ✗      |
| Pure Bash              | ✓         | ✗       | ✗       | ✗      |
| No subprocess overhead | ✓         | ✗       | ✗       | ✗      |
| Sourceable functions   | ✓         | ✗       | ✗       | ✗      |
| Direct variable assign | ✓         | ✗       | ✗       | ✗      |
| Pipeline integration   | ✓         | ✓       | ✓       | ✓      |

**When to use sed/awk instead:**
- Complex pattern matching and substitution
- Multi-line transformations
- CSV/TSV parsing with field manipulation
- When already using them in your script

---

## Overview

These utilities provide efficient text trimming operations using pure Bash parameter expansion, without external dependencies like sed or awk. Each utility works both as a standalone command-line tool and as a sourceable function in Bash scripts.

**Project Stats:**
- 6 utilities (~600 total lines of code)
- Pure Bash implementation (Bash 4+)
- 10 test suites with 90+ assertions
- Comprehensive Unicode support (preserves multi-byte characters)

---

## Utilities Reference

### Basic Trimming

| Utility | Description | Best For |
|---------|-------------|----------|
| **trim** | Removes both leading and trailing whitespace | General-purpose cleaning, config values |
| **ltrim** | Removes only leading whitespace | Indentation removal, left-aligned text |
| **rtrim** | Removes only trailing whitespace | Line ending cleanup, log processing |

### Advanced Operations

| Utility | Description | Best For |
|---------|-------------|----------|
| **trimv** | Trims and assigns result to a variable | Script variables, avoiding subshells |
| **trimall** | Normalizes whitespace (trims + collapses internal spaces) | Data normalization, comparison |
| **squeeze** | Squeezes consecutive blanks to single spaces (preserves leading/trailing) | Formatting, aligning output |

---

## Installation

### Recommended: Using the Installation Script

```bash
git clone https://github.com/Open-Technology-Foundation/trim
cd trim
sudo ./install.sh
```

This creates:
- Utility scripts in `/usr/share/yatti/trim/` (trim.bash, ltrim.bash, etc.)
- Combined module file `/usr/share/yatti/trim/trim.inc.sh` (source all at once)
- Symlinks in `/usr/local/bin/` for command-line usage

**Installation Options:**

```bash
# Custom installation directory
sudo ./install.sh --dir /opt/trim

# Install without creating symlinks
sudo ./install.sh --no-symlinks

# Uninstall
sudo ./install.sh --uninstall

# Show help
./install.sh --help
```

**Verify Installation:**

```bash
trim --version          # Should show: trim.bash 1.0.0
which trim              # Should show: /usr/local/bin/trim
```

### Quick One-Liner Installation

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Open-Technology-Foundation/trim/main/install.sh)"
```

### Manual Installation

```bash
# Clone to installation directory
git clone https://github.com/Open-Technology-Foundation/trim /usr/share/yatti/trim

# Make scripts executable
chmod +x /usr/share/yatti/trim/*.bash

# Create symlinks (optional)
for util in trim ltrim rtrim trimv trimall squeeze; do
  ln -sf /usr/share/yatti/trim/${util}.bash /usr/local/bin/${util}
done
```

---

## Basic Usage

### Command-Line Usage

Once installed, use utilities directly from the command line:

```bash
# Basic string trimming
trim "  hello world  "              # Output: "hello world"
ltrim "  hello world  "             # Output: "hello world  "
rtrim "  hello world  "             # Output: "  hello world"

# Process files
trim < input.txt > clean.txt
cat messy.log | ltrim > aligned.log

# In pipelines
grep "pattern" file.txt | trim | sort | uniq

# Normalize whitespace
trimall "  multiple    spaces   here  "    # Output: "multiple spaces here"

# Squeeze consecutive spaces (preserves leading/trailing)
squeeze "  hello    world  "               # Output: "  hello world  "

# Process escape sequences
trim -e "  \t hello \n world \t  "         # Interprets \t and \n
```

### Sourced Function Usage

Source utilities to use as functions in your scripts:

```bash
#!/bin/bash

# Source individual utilities
source /usr/share/yatti/trim/trim.bash
source /usr/share/yatti/trim/trimv.bash

# Or source all utilities at once
source /usr/share/yatti/trim/trim.inc.sh

# Use as functions
config_value=$(grep "api_key:" config.yml | cut -d':' -f2 | trim)

# Direct variable assignment with trimv (no subshell)
trimv -n result "  user input  "
echo "Cleaned: $result"

# Process data in loops
while IFS= read -r line; do
  cleaned=$(trim "$line")
  echo "Processing: $cleaned"
done < data.txt
```

---

## Command Options

| Utility | Options | Description |
|---------|---------|-------------|
| **trim** | `-e` | Process escape sequences (`\t`, `\n`, etc.) in the input |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |
| **ltrim** | `-e` | Process escape sequences in the input |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |
| **rtrim** | `-e` | Process escape sequences in the input |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |
| **trimv** | `-e` | Process escape sequences |
| | `-n varname` | Variable name to store result (defaults to `TRIM`) |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |
| **trimall** | `-e` | Process escape sequences |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |
| **squeeze** | `-e` | Process escape sequences in the input |
| | `-h, --help` | Display help message |
| | `-V, --version` | Display version information |

**Note:** Get detailed help for any utility with: `trim --help`, `ltrim --help`, etc.

---

## Practical Examples

### Quick Wins

```bash
# Clean configuration values
API_KEY=$(grep "api_key:" config.yml | cut -d':' -f2 | trim)

# Normalize command output
disk_usage=$(df -h | grep "/$" | awk '{print $5}' | trim)

# Clean user input
read -r user_input
clean_input=$(trim "$user_input")

# Remove indentation from heredocs
SQL_QUERY=$(cat <<EOF | trimall
    SELECT user_id, name
    FROM users
    WHERE active = 1
EOF
)
```

### Script Integration

```bash
#!/bin/bash
source /usr/share/yatti/trim/trim.inc.sh

# Parse CSV with proper field trimming
while IFS=, read -r id name email; do
  trimv -n ID "$id"
  trimv -n NAME "$name"
  trimv -n EMAIL "$email"
  echo "User: $ID -> $NAME ($EMAIL)"
done < users.csv

# Clean log file entries
process_logs() {
  while IFS= read -r line; do
    # Remove timestamp, trim, filter
    message=$(echo "$line" | sed 's/^\[.*\] //' | trim)
    [[ -n "$message" ]] && echo "$message"
  done < "$1"
}
```

### Pipeline Usage

```bash
# Multi-stage data cleaning
cat raw_data.txt | trim | squeeze | sort | uniq > clean_data.txt

# Verify configuration files
verify_config() {
  grep -E "^[^#]" "$1" | while IFS= read -r line; do
    key=$(echo "$line" | cut -d'=' -f1 | rtrim)
    value=$(echo "$line" | cut -d'=' -f2- | ltrim)
    echo "Config: '$key' = '$value'"
  done
}

# Compare normalized file contents
if [[ "$(trimall < file1.txt)" == "$(trimall < file2.txt)" ]]; then
  echo "Files match when normalized"
fi
```

### Advanced Variable Management

```bash
source /usr/share/yatti/trim/trimv.bash

# Clean API responses (avoids nested subshells)
trimv -n api_response "$(curl -s https://api.example.com/status)"

# Process multiline strings
trimv -n clean_query "
    SELECT *
    FROM users
    WHERE status = 'active'
"

# Handle escape sequences
trimv -e -n path_value "$PATH_WITH_ESCAPES"
```

---

## How It Works

### Core Trimming Technique

The utilities use Bash's native parameter expansion with the `[:blank:]` character class for efficient, dependency-free trimming:

```bash
# Leading whitespace removal
${string#"${string%%[![:blank:]]*}"}

# Trailing whitespace removal
${string%"${string##*[![:blank:]]}"}
```

**What is `[:blank:]`?**
- POSIX character class matching space (` `) and tab (`\t`)
- Does NOT match other Unicode whitespace (U+00A0, U+2000-U+200A, etc.)
- Perfect for standard text processing tasks

### Dual-Mode Architecture

Each utility detects whether it's being executed or sourced:

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Command mode: parse args, handle --help, process input
  [process arguments and stdin]
else
  # Function mode: just define and export function
  return 0
fi
```

This allows the same file to work as both a command and a sourceable function.

### Performance

- **Pure Bash** — No external process spawning (sed, awk, etc.)
- **Native parameter expansion** — Compiled into shell internals
- **Single pass** — Process each line once
- **Minimal memory** — Stream processing, no full-file buffering

---

## Testing

The project includes a comprehensive test suite with extensive coverage:

**Test Statistics:**
- **10 test suites** (8 unit + 2 integration)
- **90+ test assertions**
- **100% utility coverage**

**Test Categories:**
- **Unit tests** — Individual utility functionality
- **Integration tests** — Pipeline usage, sourced functions
- **Error handling** — Invalid flags, exit codes, stderr/stdout
- **Unicode support** — Emoji, RTL text, combining characters
- **Edge cases** — Empty strings, whitespace-only, multiline

**Running Tests:**

```bash
# Run all tests
./test/run-tests.sh

# Run only unit tests
./test/run-tests.sh unit

# Run only integration tests
./test/run-tests.sh integration

# Run a specific test
./test/unit/test-trim.sh
./test/unit/test-error-handling.sh
```

**Test Output:**
```
Running unit tests...
✓ test-error-handling passed
✓ test-ltrim passed
✓ test-rtrim passed
✓ test-trim passed
✓ test-trimv passed
✓ test-trimall passed
✓ test-squeeze passed
✓ test-unicode passed

Running integration tests...
✓ test-pipes passed
✓ test-sourced passed

Test Summary:
Total tests: 10
Passed: 10
All tests passed!
```

See [test/README.md](test/README.md) for detailed test documentation.

---

## Performance

### Benchmarks

Pure Bash parameter expansion is significantly faster than spawning external processes:

```bash
# trim (pure Bash) — ~0.001s per call
time trim "  hello world  "

# sed equivalent — ~0.01s per call (10x slower)
time echo "  hello world  " | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'

# For 10,000 iterations, the difference is substantial
```

### Best Practices

**For Maximum Performance:**
- Source utilities when calling repeatedly in loops (avoids script execution overhead)
- Use `trimv` for direct variable assignment (avoids subshell spawning)
- Process streams line-by-line rather than reading entire files into memory

**When Processing Large Files:**
- Utilities stream process (no full-file buffering)
- Performance is linear with file size
- Consider GNU parallel for multi-core processing of massive datasets

---

## Advanced Usage

### Loading All Utilities at Once

```bash
# Source the combined module file
source /usr/share/yatti/trim/trim.inc.sh

# Now all utilities are available as functions
result1=$(trim "  text  ")
result2=$(ltrim "  text  ")
trimv -n result3 "  text  "
```

### Custom Trim Functions

Build on the utilities for specialized needs:

```bash
source /usr/share/yatti/trim/trim.bash

# Trim and convert to lowercase
trimlower() {
  local result
  result=$(trim "$1")
  echo "${result,,}"
}

# Trim and validate non-empty
trim_required() {
  local result
  result=$(trim "$1")
  if [[ -z "$result" ]]; then
    echo "Error: Required value is empty" >&2
    return 1
  fi
  echo "$result"
}
```

### Error Handling Patterns

```bash
# Check if utility is available
if ! command -v trim &>/dev/null; then
  echo "Error: trim utility not installed" >&2
  exit 1
fi

# Handle errors with trimv
source /usr/share/yatti/trim/trimv.bash
if ! trimv -n result "  $user_input  "; then
  echo "Error: Failed to trim input" >&2
  exit 1
fi

# Validate variable names
if ! trimv -n "123invalid" "test" 2>/dev/null; then
  echo "Invalid variable name rejected (expected)"
fi
```

---

## Limitations & Gotchas

### Bash Version Requirement

- **Requires Bash 4.0+** — Uses features not available in older Bash or POSIX sh
- Check version: `bash --version`

### Whitespace Handling

**Important:** These utilities use `[:blank:]` which only matches:
- Space (` `, U+0020)
- Tab (`\t`, U+0009)

**NOT trimmed:**
- Non-breaking space (U+00A0)
- Unicode whitespace (U+2000-U+200A, U+202F, U+205F, U+3000)
- Zero-width space (U+200B)
- Other Unicode separators

This is **intentional** for standard text processing. If you need Unicode whitespace handling, consider other tools.

### trimv Sourcing Requirement

**`trimv` must be sourced, not executed:**

```bash
# ✗ WRONG — Variable won't be set in parent shell
./trimv.bash -n result "  text  "
echo "$result"  # Empty!

# ✓ CORRECT — Source first
source ./trimv.bash
trimv -n result "  text  "
echo "$result"  # Works!
```

**Why?** Subprocesses cannot modify parent shell variables. This is a fundamental Unix/shell limitation.

### Binary Data

- These utilities process **text**, not binary data
- Bash's `read` command interprets input as text
- Null bytes (`\0`) and other binary content may cause unexpected behavior
- For binary processing, use specialized tools (xxd, hexdump, etc.)

### Line Endings

- Utilities preserve line endings as-is
- Windows CRLF (`\r\n`) — `\r` is NOT trimmed by `[:blank:]`
- Use `dos2unix` or `sed` for line ending conversion if needed

---

## When NOT to Use

These utilities are excellent for most shell scripting needs, but consider alternatives when:

### File Size Concerns

- **Very large files (GB+)** — Consider streaming tools optimized for massive datasets
- **Memory-constrained environments** — While efficient, massive files still consume resources

### Unicode Whitespace Requirements

- If you need to trim Unicode whitespace (U+00A0, U+2000-U+200A, etc.)
- Consider: `sed`, `perl`, `python` with Unicode support

### POSIX Compatibility Required

- These utilities require **Bash 4+**
- For POSIX sh compatibility, use traditional `sed`/`awk`

### Complex Text Processing

- Multi-line regex patterns
- Field extraction with complex delimiters
- CSV parsing with quoted fields
- Consider: `awk`, `perl`, `python`

### Binary Data Processing

- Not suitable for binary files
- Use: `xxd`, `hexdump`, `od`, or language-specific binary tools

---

## Troubleshooting

### Command Not Found

**Problem:** `bash: trim: command not found`

**Solutions:**
```bash
# Check if installed
which trim

# Check installation path
ls -la /usr/local/bin/trim

# Reinstall if needed
sudo ./install.sh

# Use absolute path
/usr/share/yatti/trim/trim.bash "  text  "

# Or source it
source /usr/share/yatti/trim/trim.bash
trim "  text  "
```

### trimv Variable Not Set

**Problem:** Variable remains empty after `trimv -n varname "text"`

**Solution:** You must **source** trimv first:
```bash
# Source the utility
source /usr/share/yatti/trim/trimv.bash

# Now it works
trimv -n result "  hello  "
echo "$result"
```

### Unexpected Unicode Behavior

**Problem:** Non-breaking spaces or other Unicode whitespace not trimmed

**Explanation:** By design, utilities only trim `[:blank:]` (space + tab), not all Unicode whitespace.

**Solution:** If you need Unicode whitespace handling:
```bash
# Use sed with extended Unicode support
echo "  text  " | sed 's/^[\s\u00A0\u2000-\u200A]*//;s/[\s\u00A0\u2000-\u200A]*$//'

# Or Python
python3 -c "import sys; print(sys.stdin.read().strip())" <<< "  text  "
```

### Performance Issues with Large Files

**Problem:** Slow processing of massive files

**Solutions:**
```bash
# 1. Use GNU parallel for multi-core processing
parallel --pipe -N 1000 trim < huge_file.txt > output.txt

# 2. Process in chunks
split -l 100000 huge_file.txt chunk_
for chunk in chunk_*; do
  trim < "$chunk" > "clean_$chunk" &
done
wait

# 3. Consider specialized tools
# For GB+ files, use awk or sed which may have optimizations
```

### Permission Denied

**Problem:** `./install.sh: Permission denied`

**Solutions:**
```bash
# Make executable
chmod +x install.sh

# Or run with bash
bash install.sh

# For installation, use sudo
sudo ./install.sh
```

---

## Contributing

We welcome contributions! Here's how to get involved:

### Reporting Issues

Found a bug or have a feature request?
- Open an issue: [github.com/Open-Technology-Foundation/trim/issues](https://github.com/Open-Technology-Foundation/trim/issues)
- Include: Bash version, OS, steps to reproduce, expected vs actual behavior

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. **Write tests** for new functionality (required)
4. Ensure all tests pass: `./test/run-tests.sh`
5. Follow existing code style (see code comments)
6. Commit with clear messages
7. Submit pull request with description of changes

### Development Setup

```bash
# Clone repository
git clone https://github.com/Open-Technology-Foundation/trim
cd trim

# Test your changes
./test/run-tests.sh

# Test individual utilities locally
./trim.bash "  test  "
source ./trimv.bash && trimv -n result "  test  "
```

### Code Standards

- Follow existing patterns (dual-mode, parameter expansion)
- Add comprehensive tests for new features
- Update help text and documentation
- Ensure shellcheck passes (if available)

---

## License

GNU General Public License v3.0

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the [LICENSE](LICENSE) file for details.

---

## Links & Resources

- **Repository:** [github.com/Open-Technology-Foundation/trim](https://github.com/Open-Technology-Foundation/trim)
- **Issues:** [github.com/Open-Technology-Foundation/trim/issues](https://github.com/Open-Technology-Foundation/trim/issues)
- **Latest Release:** [github.com/Open-Technology-Foundation/trim/releases](https://github.com/Open-Technology-Foundation/trim/releases)

---

**Made with 💙 by the Open Technology Foundation**

#fin
