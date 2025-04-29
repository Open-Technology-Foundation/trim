#!/usr/bin/env bash
# Integration tests for sourced trimming functions

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source the module files
source "$ROOT_DIR/trim.bash"
source "$ROOT_DIR/ltrim.bash"
source "$ROOT_DIR/rtrim.bash"
source "$ROOT_DIR/trimall.bash"
source "$ROOT_DIR/trimv.bash"

# Test using sourced trim function
test_sourced_trim() {
  local input="  hello world  "
  local expected="hello world"
  local actual="$(trim "$input")"
  
  assert_equals "$actual" "$expected" "Using sourced trim function"
}

# Test using sourced ltrim function
test_sourced_ltrim() {
  local input="  hello world  "
  local expected="hello world  "
  local actual="$(ltrim "$input")"
  
  assert_equals "$actual" "$expected" "Using sourced ltrim function"
}

# Test using sourced rtrim function
test_sourced_rtrim() {
  local input="  hello world  "
  local expected="  hello world"
  local actual="$(rtrim "$input")"
  
  assert_equals "$actual" "$expected" "Using sourced rtrim function"
}

# Test using sourced trimall function
test_sourced_trimall() {
  local input="  multiple    spaces   here  "
  local expected="multiple spaces here"
  local actual="$(trimall "$input")"
  
  assert_equals "$actual" "$expected" "Using sourced trimall function"
}

# Test using sourced trimv function
test_sourced_trimv() {
  local test_var=""
  
  # Direct function call
  trimv -n test_var "  hello world  "
  
  local expected="hello world"
  assert_equals "$test_var" "$expected" "Using sourced trimv function"
}

# Test using multiple sourced functions together
test_sourced_combination() {
  local input="  hello    world  "
  
  # Compare different function results
  local trim_result="$(trim "$input")"
  local ltrim_rtrim_result="$(rtrim "$(ltrim "$input")")"
  local trimall_result="$(trimall "$input")"
  
  assert_equals "$trim_result" "hello    world" "trim preserves internal spaces"
  assert_equals "$ltrim_rtrim_result" "$trim_result" "ltrim + rtrim equals trim"
  assert_equals "$trimall_result" "hello world" "trimall normalizes internal spaces"
}

# Test using sourced functions with stdin
test_sourced_stdin() {
  local input="  hello from stdin  "
  
  # Test each function with stdin
  local trim_result="$(echo "$input" | trim)"
  local ltrim_result="$(echo "$input" | ltrim)"
  local rtrim_result="$(echo "$input" | rtrim)"
  
  assert_equals "$trim_result" "hello from stdin" "sourced trim with stdin"
  assert_equals "$ltrim_result" "hello from stdin  " "sourced ltrim with stdin"
  assert_equals "$rtrim_result" "  hello from stdin" "sourced rtrim with stdin"
}

# Test using sourced trimv with stdin
test_sourced_trimv_stdin() {
  local test_var=""
  local input="  hello from stdin  "
  
  # Use echo to pipe to trimv
  echo "$input" | trimv -n test_var
  
  local expected="hello from stdin"
  assert_equals "$test_var" "$expected" "sourced trimv with stdin"
}

# Run all tests
test_sourced_trim
test_sourced_ltrim
test_sourced_rtrim
test_sourced_trimall
test_sourced_trimv
test_sourced_combination
test_sourced_stdin
test_sourced_trimv_stdin

echo "All sourced function tests passed!"
exit 0

#fin