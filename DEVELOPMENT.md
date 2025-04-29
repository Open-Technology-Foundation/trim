# Development Guide

This document provides guidelines and information for developers who want to contribute to the Bash String Trim Utilities project.

## Project Structure

```
/
├── *.bash          # Core utility implementation files
├── *               # Wrapper scripts (symlinked to .bash files)
├── LICENSE         # GNU GPL v3 license
├── README.md       # User documentation
├── DEVELOPMENT.md  # This development guide
├── install.sh      # Installation script
└── test/           # Test suite
    ├── fixtures/   # Test input and expected output files
    ├── unit/       # Unit tests for each utility
    ├── integration/# Integration tests
    └── run-tests.sh# Test runner script
```

## Development Environment

- Bash 5.2+ is recommended for development
- Use a modern text editor with bash syntax highlighting
- Enable shell script linting in your editor (shellcheck support recommended)

## Coding Standards

### Bash Style Guidelines

1. **Indentation**: Use 2-space indentation (no tabs)
2. **Line Length**: Keep lines to a reasonable length (~80 characters where possible)
3. **Functions**:
   - Use meaningful function names in lowercase
   - Document function purpose with comments
   - Use `local` for function-scoped variables
4. **Variables**:
   - Use meaningful variable names
   - Use lowercase for local variables
   - Use `declare` with appropriate flags where possible (e.g., `-i` for integers)
5. **Command Substitution**: Use `$(command)` rather than backticks
6. **Conditionals**: Prefer `[[` over `[` for tests
7. **Error Handling**: Always set `set -euo pipefail` for standalone scripts
8. **Script End**: Always end scripts with `#fin` on the last line

### Documentation

- Each script should include a header comment with:
  - Purpose/description
  - Usage examples
  - Options
  - Related commands
- Add clear, concise comments for complex logic
- Keep usage and help text updated when adding features

## Core Implementation Patterns

### String Trimming Techniques

The utilities use efficient Bash parameter expansion patterns:

- **Leading whitespace removal**: `${string#"${string%%[![:blank:]]*}"}`
- **Trailing whitespace removal**: `${string%"${string##*[![:blank:]]}"}`
- **Whitespace normalization**: Word splitting with `set -- $string; echo "$*"`

### Script/Module Dual Usage Pattern

All utilities follow this pattern for dual usage (as script or sourced):

```bash
# Function definition
function_name() {
  # Implementation
}
declare -fx function_name

# Script mode detection
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  # Process arguments, show help, etc.
  function_name "$@"
fi
```

### Command-Line Argument Parsing

For parsing command-line arguments:

```bash
# Simple flag handling
if [[ "$1" == '-e' ]]; then
  # Handle -e flag
  shift
fi

# Help flags
if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  # Show help
  exit 0
fi
```

### Secure Temporary File Handling

When using temporary files (like in `trimv`):

```bash
# Create secure temporary file
tmp_file=$(mktemp -t "prefix_XXXXXXXXXX")
chmod 600 "$tmp_file"

# Use the file...

# Clean up securely
rm -f "$tmp_file" 2>/dev/null || true
```

## Testing

### Test Structure

Tests are organized into:

1. **Unit Tests**: Test individual functions in isolation
2. **Integration Tests**: Test how utilities work together in real-world scenarios

### Writing Tests

When adding new tests:

```bash
# Example test function format
test_function_name() {
  local input="test input"
  local expected="expected output"
  local actual="$($COMMAND "$input")"
  
  assert_equals "$actual" "$expected" "Test description"
}
```

### Running Tests

```bash
# Run all tests
./test/run-tests.sh

# Run specific test categories
./test/run-tests.sh unit
./test/run-tests.sh integration
```

## Adding New Utilities

When adding a new utility:

1. Create the implementation file (e.g., `newutil.bash`)
2. Follow the dual-use pattern shown above
3. Add unit tests in `test/unit/test-newutil.sh`
4. Add integration tests as appropriate
5. Update the README.md to document the new utility
6. Update the installation script to include the new utility

## Release Process

1. Ensure all tests pass: `./test/run-tests.sh`
2. Update documentation if necessary
3. Create new release tag (if using versioning)
4. Update the CHANGELOG.md file (if maintained)

## Troubleshooting

Common issues:

- **Subprocess variable scope**: Remember that variables set in subshells are not available in the parent shell
- **Parameter expansion complexity**: Break down complex parameter expansions into steps with comments
- **Whitespace handling**: Be careful with word splitting and quoting

#fin