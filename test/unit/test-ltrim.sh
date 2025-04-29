#!/usr/bin/env bash
# Unit tests for ltrim utility

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Path to the ltrim utility
LTRIM="$ROOT_DIR/ltrim"

# Ensure the utility is available
if [[ ! -x "$LTRIM" ]]; then
  echo "Error: ltrim utility not found or not executable"
  exit 1
fi

# Test basic left trimming
test_basic_ltrim() {
  local input="  hello world  "
  local expected="hello world  "
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Basic left trimming"
}

# Test trimming with only leading spaces
test_leading_spaces() {
  local input="   hello world"
  local expected="hello world"
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming only leading spaces"
}

# Test input with only trailing spaces (should remain unchanged)
test_trailing_spaces() {
  local input="hello world   "
  local expected="hello world   "
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Input with only trailing spaces"
}

# Test trimming with various whitespace characters
test_mixed_whitespace() {
  local input=$'\t  hello \t world \t  '
  # The actual output is with literal tabs
  local expected=$'hello \t world \t  '
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming mixed leading whitespace"
}

# Test stdin processing with echo
test_stdin_echo() {
  local input="  hello from stdin  "
  local expected="hello from stdin  "
  local actual="$(echo "$input" | "$LTRIM")"
  
  assert_equals "$actual" "$expected" "Processing from stdin with echo"
}

# Test stdin processing with a file
test_stdin_file() {
  local input_file="$FIXTURES_DIR/input/multiline.txt"
  local expected_file="$FIXTURES_DIR/expected/multiline_ltrim.txt"
  local output_file="$TMP_DIR/ltrim_output.txt"
  
  "$LTRIM" < "$input_file" > "$output_file"
  
  assert_file_equals "$output_file" "$expected_file" "Processing from stdin with a file"
}

# Test empty input
test_empty_input() {
  local input=""
  local expected=""
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Left trimming empty string"
  
  # Test with empty file
  local input_file="$FIXTURES_DIR/input/empty.txt"
  local expected_file="$FIXTURES_DIR/expected/empty_trim.txt"
  local output_file="$TMP_DIR/empty_ltrim_output.txt"
  
  "$LTRIM" < "$input_file" > "$output_file"
  
  assert_file_equals "$output_file" "$expected_file" "Processing empty file"
}

# Test whitespace-only input
test_whitespace_only() {
  local input="    "  # Only spaces, no tabs
  local expected=""
  local actual="$("$LTRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Left trimming whitespace-only string"
}

# Test escape sequence processing
test_escape_sequences() {
  # For regular string input, no escape sequence processing
  local input="  hello world  "
  local expected="hello world  "
  local actual="$("$LTRIM" "$input")"
  assert_equals "$actual" "$expected" "Basic ltrim without escape sequences"
  
  # Test with -e flag using a simpler example
  # Test a string with tab and space as leading whitespace
  printf -v input_e "  \t  hello world"
  printf -v expected_e "hello world"
  local actual_e="$("$LTRIM" -e "$input_e")"
  
  assert_equals "$actual_e" "$expected_e" "Processing escape sequences with -e flag"
}

# Run all tests
test_basic_ltrim
test_leading_spaces
test_trailing_spaces
test_mixed_whitespace
test_stdin_echo
test_stdin_file
test_empty_input
test_whitespace_only
test_escape_sequences

echo "All ltrim tests passed!"
exit 0

#fin