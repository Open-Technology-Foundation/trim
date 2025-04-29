#!/usr/bin/env bash
# Integration tests for piping between trim utilities

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Paths to utilities
TRIM="$ROOT_DIR/trim"
LTRIM="$ROOT_DIR/ltrim"
RTRIM="$ROOT_DIR/rtrim"
TRIMALL="$ROOT_DIR/trimall"
TRIMV="$ROOT_DIR/trimv"

# Ensure all utilities are available
for util in "$TRIM" "$LTRIM" "$RTRIM" "$TRIMALL" "$TRIMV"; do
  if [[ ! -x "$util" ]]; then
    echo "Error: $(basename "$util") utility not found or not executable"
    exit 1
  fi
done

# Test piping ltrim to rtrim (equivalent to trim)
test_ltrim_to_rtrim() {
  local input="  hello world  "
  local expected="hello world"
  local actual="$(echo "$input" | "$LTRIM" | "$RTRIM")"
  local trim_actual="$(echo "$input" | "$TRIM")"
  
  assert_equals "$actual" "$expected" "Piping ltrim to rtrim"
  assert_equals "$actual" "$trim_actual" "ltrim | rtrim equals trim"
}

# Test piping with trimall
test_trimall_pipeline() {
  local input="  multiple    spaces   here  "
  local expected="multiple spaces here"
  local actual="$(echo "$input" | "$TRIMALL")"
  
  assert_equals "$actual" "$expected" "Using trimall in a pipeline"
  
  # Compare with trim for leading/trailing spaces
  local trim_actual="$(echo "$input" | "$TRIM")"
  local expected_trim="multiple    spaces   here"
  
  assert_equals "$trim_actual" "$expected_trim" "trim versus trimall behavior"
}

# Test complex pipeline with all utilities
test_complex_pipeline() {
  local input="  complex     pipeline   test  "
  
  # Test different pipelines and compare results
  local trim_result="$(echo "$input" | "$TRIM")"
  local ltrim_rtrim_result="$(echo "$input" | "$LTRIM" | "$RTRIM")"
  local trimall_result="$(echo "$input" | "$TRIMALL")"
  
  assert_equals "$trim_result" "$ltrim_rtrim_result" "trim equals ltrim | rtrim"
  assert_equals "$trimall_result" "complex pipeline test" "trimall normalizes all spaces"
}

# Test piping to trimv - using stdout mode instead of variable assignment
test_pipe_to_trimv() {
  local input="  hello from pipeline  "
  
  # Use the trimv in stdout mode (no -n flag) with a pipe
  local actual="$(echo "$input" | "$TRIMV")"
  local expected="hello from pipeline"
  
  assert_equals "$actual" "$expected" "Piping to trimv (stdout mode)"
}

# Test piping between multiple utilities with a file
test_file_pipeline() {
  local input_file="$FIXTURES_DIR/input/multiline.txt"
  local output_file="$TMP_DIR/pipeline_output.txt"
  
  # Process with a pipeline of different utilities
  cat "$input_file" | "$LTRIM" | "$RTRIM" > "$output_file"
  
  local expected_file="$FIXTURES_DIR/expected/multiline_trim.txt"
  
  assert_file_equals "$output_file" "$expected_file" "Complex pipeline processing with a file"
}

# Run all tests
test_ltrim_to_rtrim
test_trimall_pipeline
test_complex_pipeline
test_pipe_to_trimv
test_file_pipeline

echo "All pipe integration tests passed!"
exit 0

#fin