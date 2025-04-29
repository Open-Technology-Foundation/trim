#!/usr/bin/env bash
# Unit tests for trimv utility

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Path to the trimv utility
TRIMV="$ROOT_DIR/trimv"

# Ensure the utility is available
if [[ ! -x "$TRIMV" ]]; then
  echo "Error: trimv utility not found or not executable"
  exit 1
fi

# Test basic variable assignment
test_basic_variable_assignment() {
  # Use a unique variable name to avoid conflicts
  local test_var=""
  # Use the trimv utility to assign a trimmed value
  "$TRIMV" -n test_var "  hello world  "
  
  local expected="hello world"
  assert_equals "$test_var" "$expected" "Basic variable assignment"
}

# Test variable assignment with escape sequences
test_escape_sequence_assignment() {
  local test_var=""
  "$TRIMV" -e -n test_var "  hello\tworld\n  "
  
  local expected=$'hello\tworld\n'
  assert_equals "$test_var" "$expected" "Variable assignment with escape sequences"
}

# Test stdin assignment
test_stdin_assignment() {
  local test_var=""
  local input="  hello from stdin  "
  echo "$input" | "$TRIMV" -n test_var
  
  local expected="hello from stdin"
  assert_equals "$test_var" "$expected" "Variable assignment from stdin echo"
}

# Test multiline stdin assignment
test_multiline_stdin_assignment() {
  local test_var=""
  # Create a temporary multiline input
  local input_file="$(create_temp_multiline_file << EOF
  line one  
  line two  
	line three with tab	
EOF
)"
  
  # Use trimv with stdin from file
  "$TRIMV" -n test_var < "$input_file"
  
  local expected="line one
line two
line three with tab"
  
  assert_equals "$test_var" "$expected" "Multiline variable assignment from stdin"
}

# Test file input assignment
test_file_input_assignment() {
  local test_var=""
  "$TRIMV" -n test_var < "$FIXTURES_DIR/input/multiline.txt"
  
  # Expected result should have leading and trailing whitespace removed from each line
  local expected="Line one with leading and trailing spaces
Line two with more leading spaces
Line three with no leading spaces
Line four with a tab

Line six after an empty line"
  
  assert_equals "$test_var" "$expected" "Variable assignment from file"
}

# Test default output (without -n)
test_default_output() {
  local input="  hello world  "
  local expected="hello world"
  local actual="$("$TRIMV" "$input")"
  
  assert_equals "$actual" "$expected" "Default output behavior"
}

# Test empty input
test_empty_input() {
  local test_var="previous value"
  "$TRIMV" -n test_var ""
  
  local expected=""
  assert_equals "$test_var" "$expected" "Empty string assignment"
  
  # Test with empty file
  test_var="previous value"
  "$TRIMV" -n test_var < "$FIXTURES_DIR/input/empty.txt"
  
  expected=""
  assert_equals "$test_var" "$expected" "Empty file assignment"
}

# Test whitespace-only input
test_whitespace_only() {
  local test_var="previous value"
  "$TRIMV" -n test_var "    "  # Only spaces, no tabs
  
  local expected=""
  assert_equals "$test_var" "$expected" "Whitespace-only string assignment"
}

# Test invalid variable name
test_invalid_variable_name() {
  # This should return an error code
  if "$TRIMV" -n "123invalid" "test" 2>/dev/null; then
    echo "Test failed: Expected error for invalid variable name"
    return 1
  else
    echo -e "${GREEN}✓ Test passed: Invalid variable name properly rejected${NC}"
    return 0
  fi
}

# Run all tests
test_basic_variable_assignment
test_escape_sequence_assignment
test_stdin_assignment
test_multiline_stdin_assignment
test_file_input_assignment
test_default_output
test_empty_input
test_whitespace_only
test_invalid_variable_name

echo "All trimv tests passed!"
exit 0

#fin