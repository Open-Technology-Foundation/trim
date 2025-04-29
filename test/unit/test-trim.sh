#!/usr/bin/env bash
# Unit tests for trim utility

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Path to the trim utility
TRIM="$ROOT_DIR/trim"

# Ensure the utility is available
if [[ ! -x "$TRIM" ]]; then
  echo "Error: trim utility not found or not executable"
  exit 1
fi

# Test basic string trimming
test_basic_trim() {
  local input="  hello world  "
  local expected="hello world"
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Basic string trimming"
}

# Test trimming with only leading spaces
test_leading_spaces() {
  local input="   hello world"
  local expected="hello world"
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming leading spaces"
}

# Test trimming with only trailing spaces
test_trailing_spaces() {
  local input="hello world   "
  local expected="hello world"
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming trailing spaces"
}

# Test trimming with various whitespace characters
test_mixed_whitespace() {
  local input=$'\t  hello \t world \t  '
  local expected="hello \t world"
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming mixed whitespace"
}

# Test stdin processing with echo
test_stdin_echo() {
  local input="  hello from stdin  "
  local expected="hello from stdin"
  local actual="$(echo "$input" | "$TRIM")"
  
  assert_equals "$actual" "$expected" "Processing from stdin with echo"
}

# Test stdin processing with a file
test_stdin_file() {
  local input_file="$FIXTURES_DIR/input/multiline.txt"
  local expected_file="$FIXTURES_DIR/expected/multiline_trim.txt"
  local output_file="$TMP_DIR/trim_output.txt"
  
  "$TRIM" < "$input_file" > "$output_file"
  
  assert_file_equals "$output_file" "$expected_file" "Processing from stdin with a file"
}

# Test empty input
test_empty_input() {
  local input=""
  local expected=""
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming empty string"
  
  # Test with empty file
  local input_file="$FIXTURES_DIR/input/empty.txt"
  local expected_file="$FIXTURES_DIR/expected/empty_trim.txt"
  local output_file="$TMP_DIR/empty_output.txt"
  
  "$TRIM" < "$input_file" > "$output_file"
  
  assert_file_equals "$output_file" "$expected_file" "Processing empty file"
}

# Test whitespace-only input
test_whitespace_only() {
  local input="    "  # Only spaces, no tabs
  local expected=""
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Trimming whitespace-only string"
  
  # Test with whitespace-only file
  local input_file="$FIXTURES_DIR/input/whitespace.txt"
  local expected_file="$FIXTURES_DIR/expected/whitespace_trim.txt"
  local output_file="$TMP_DIR/whitespace_output.txt"
  
  "$TRIM" < "$input_file" > "$output_file"
  
  assert_file_equals "$output_file" "$expected_file" "Processing whitespace-only file"
}

# Test escape sequence processing
test_escape_sequences() {
  local input=$'  \\t\\n  hello  \\t\\n  '
  local expected=$'\\t\\n  hello  \\t\\n'
  local actual="$("$TRIM" "$input")"
  
  assert_equals "$actual" "$expected" "Default behavior with escape sequences"
  
  # Test with -e flag
  local input_e=$'  \\t\\n  hello  \\t\\n  '
  local expected_e=$'\t\n  hello  \t\n'
  local actual_e="$("$TRIM" -e "$input_e")"
  
  assert_equals "$actual_e" "$expected_e" "Processing escape sequences with -e flag"
}

# Run all tests
test_basic_trim
test_leading_spaces
test_trailing_spaces
test_mixed_whitespace
test_stdin_echo
test_stdin_file
test_empty_input
test_whitespace_only
test_escape_sequences

echo "All trim tests passed!"
exit 0

#fin