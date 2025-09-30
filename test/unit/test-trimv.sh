#!/usr/bin/env bash
# Unit tests for trimv utility

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source the trimv module (must be sourced for variable assignment to work)
TRIMV_MODULE="$ROOT_DIR/trimv.bash"
if [[ ! -f "$TRIMV_MODULE" ]]; then
  echo "Error: trimv module not found at $TRIMV_MODULE"
  exit 1
fi

source "$TRIMV_MODULE"

# Test basic variable assignment
test_basic_variable_assignment() {
  # Use a unique variable name to avoid conflicts
  local test_var=""
  # Use the trimv utility to assign a trimmed value
  trimv -n test_var "  hello world  "

  local expected="hello world"
  assert_equals "$test_var" "$expected" "Basic variable assignment"
}

# Test variable assignment with escape sequences
test_escape_sequence_assignment() {
  local test_var=""
  trimv -e -n test_var "  hello\tworld\n  "
  
  local expected=$'hello\tworld\n'
  assert_equals "$test_var" "$expected" "Variable assignment with escape sequences"
}

# Test stdin assignment
test_stdin_assignment() {
  local test_var=""
  local input="  hello from stdin  "
  # Use process substitution instead of pipe to avoid subshell
  trimv -n test_var < <(echo "$input")

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
  trimv -n test_var < "$input_file"
  
  local expected="line one
line two
line three with tab"
  
  assert_equals "$test_var" "$expected" "Multiline variable assignment from stdin"
}

# Test file input assignment
test_file_input_assignment() {
  local test_var=""
  trimv -n test_var < "$FIXTURES_DIR/input/multiline.txt"
  
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
  local actual="$(trimv "$input")"
  
  assert_equals "$actual" "$expected" "Default output behavior"
}

# Test empty input
test_empty_input() {
  local test_var="previous value"
  trimv -n test_var ""
  
  local expected=""
  assert_equals "$test_var" "$expected" "Empty string assignment"
  
  # Test with empty file
  test_var="previous value"
  trimv -n test_var < "$FIXTURES_DIR/input/empty.txt"
  
  expected=""
  assert_equals "$test_var" "$expected" "Empty file assignment"
}

# Test whitespace-only input
test_whitespace_only() {
  local test_var="previous value"
  trimv -n test_var "    "  # Only spaces, no tabs
  
  local expected=""
  assert_equals "$test_var" "$expected" "Whitespace-only string assignment"
}

# Test invalid variable name
test_invalid_variable_name() {
  # This should return an error code
  if trimv -n "123invalid" "test" 2>/dev/null; then
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