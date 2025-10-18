#!/usr/bin/env bash
# Unit tests for error handling across all trim utilities
# Tests exit codes, invalid flags, stderr output, and error conditions

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Utilities to test
TRIM="$ROOT_DIR/trim"
LTRIM="$ROOT_DIR/ltrim"
RTRIM="$ROOT_DIR/rtrim"
TRIMALL="$ROOT_DIR/trimall"
SQUEEZE="$ROOT_DIR/squeeze"

# Test helper: Assert exit code
assert_exit_code() {
  local actual=$1
  local expected=$2
  local message="${3:-}"

  if [[ $actual -eq $expected ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}${message:+: $message}"
    return 0
  else
    echo -e "${RED}✗ Exit code test failed${NC}${message:+: $message}"
    echo -e "Expected exit code: $expected"
    echo -e "Actual exit code:   $actual"
    return 1
  fi
}

# Test helper: Assert stderr is not empty
assert_stderr_not_empty() {
  local stderr="$1"
  local message="${2:-}"

  if [[ -n "$stderr" ]]; then
    echo -e "${GREEN}✓ Stderr test passed${NC}${message:+: $message}"
    return 0
  else
    echo -e "${RED}✗ Stderr test failed${NC}${message:+: $message}"
    echo -e "Expected: Non-empty stderr"
    echo -e "Actual:   Empty stderr"
    return 1
  fi
}

# Test: Invalid flag for trim
test_trim_invalid_flag() {
  local stderr_file="$TMP_DIR/stderr.txt"

  # Should fail with exit code 22 (EINVAL) or 1
  "$TRIM" --invalid-flag 2>"$stderr_file" >/dev/null || local exit_code=$?

  # Exit code should be non-zero (either 22 or 1)
  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: trim rejects invalid flag"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: trim should reject invalid flag"
    return 1
  fi

  # Should output error message to stderr
  assert_stderr_not_empty "$(cat "$stderr_file")" "Error message sent to stderr"
}

# Test: Invalid flag for ltrim
test_ltrim_invalid_flag() {
  local stderr_file="$TMP_DIR/stderr.txt"

  "$LTRIM" -x "test" 2>"$stderr_file" >/dev/null || local exit_code=$?

  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: ltrim rejects invalid flag"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: ltrim should reject invalid flag"
    return 1
  fi

  assert_stderr_not_empty "$(cat "$stderr_file")" "Error message sent to stderr"
}

# Test: Invalid flag for rtrim
test_rtrim_invalid_flag() {
  local stderr_file="$TMP_DIR/stderr.txt"

  "$RTRIM" --bad-option 2>"$stderr_file" >/dev/null || local exit_code=$?

  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: rtrim rejects invalid flag"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: rtrim should reject invalid flag"
    return 1
  fi

  assert_stderr_not_empty "$(cat "$stderr_file")" "Error message sent to stderr"
}

# Test: Invalid flag for trimall
test_trimall_invalid_flag() {
  local stderr_file="$TMP_DIR/stderr.txt"

  "$TRIMALL" -z 2>"$stderr_file" >/dev/null || local exit_code=$?

  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: trimall rejects invalid flag"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: trimall should reject invalid flag"
    return 1
  fi

  assert_stderr_not_empty "$(cat "$stderr_file")" "Error message sent to stderr"
}

# Test: Invalid flag for squeeze
test_squeeze_invalid_flag() {
  local stderr_file="$TMP_DIR/stderr.txt"

  "$SQUEEZE" --unknown 2>"$stderr_file" >/dev/null || local exit_code=$?

  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: squeeze rejects invalid flag"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: squeeze should reject invalid flag"
    return 1
  fi

  assert_stderr_not_empty "$(cat "$stderr_file")" "Error message sent to stderr"
}

# Test: trimv invalid variable name
test_trimv_invalid_varname() {
  source "$ROOT_DIR/trimv.bash"

  local stderr_file="$TMP_DIR/stderr.txt"

  # Test various invalid names
  local invalid_names=(
    "123invalid"      # Starts with number
    "var-name"        # Contains dash
    "var.name"        # Contains dot
    "var name"        # Contains space
    "var\$name"       # Contains dollar sign
  )

  local -i passed=0
  local -i total=${#invalid_names[@]}

  for name in "${invalid_names[@]}"; do
    if trimv -n "$name" "test" 2>"$stderr_file" >/dev/null; then
      echo -e "${RED}✗ Test failed${NC}: Variable name '$name' should be rejected"
    else
      ((passed+=1))
    fi
  done

  if [[ $passed -eq $total ]]; then
    echo -e "${GREEN}✓ Test passed${NC}: All invalid variable names rejected ($passed/$total)"
    return 0
  else
    echo -e "${RED}✗ Test failed${NC}: Some invalid names accepted ($passed/$total rejected)"
    return 1
  fi
}

# Test: trimv valid variable names that might seem invalid
test_trimv_valid_varnames() {
  source "$ROOT_DIR/trimv.bash"

  # These should all be VALID
  local valid_names=(
    "my_var"          # Underscores OK
    "_private"        # Leading underscore OK
    "var123"          # Numbers at end OK
    "var123name"      # Numbers in middle OK
    "UPPERCASE"       # All caps OK
    "if"              # Reserved word but valid var name
    "then"            # Reserved word but valid var name
  )

  local -i passed=0
  local -i total=${#valid_names[@]}

  for name in "${valid_names[@]}"; do
    if trimv -n "$name" "test" 2>/dev/null; then
      ((passed+=1))
    else
      echo -e "${RED}✗ Test failed${NC}: Variable name '$name' should be accepted"
    fi
  done

  if [[ $passed -eq $total ]]; then
    echo -e "${GREEN}✓ Test passed${NC}: All valid variable names accepted ($passed/$total)"
    return 0
  else
    echo -e "${RED}✗ Test failed${NC}: Some valid names rejected ($passed/$total accepted)"
    return 1
  fi
}

# Test: Success exit code (0) for valid operations
test_success_exit_codes() {
  # All these should exit with code 0
  "$TRIM" "test" >/dev/null
  assert_exit_code $? 0 "trim with valid input"

  echo "test" | "$LTRIM" >/dev/null
  assert_exit_code $? 0 "ltrim with stdin"

  "$RTRIM" "  test  " >/dev/null
  assert_exit_code $? 0 "rtrim with valid input"

  "$TRIMALL" "  a  b  " >/dev/null
  assert_exit_code $? 0 "trimall with valid input"

  "$SQUEEZE" "a    b" >/dev/null
  assert_exit_code $? 0 "squeeze with valid input"
}

# Test: Empty input handling (should succeed with exit 0)
test_empty_input_exit_code() {
  "$TRIM" "" >/dev/null
  assert_exit_code $? 0 "trim with empty string"

  echo "" | "$LTRIM" >/dev/null
  assert_exit_code $? 0 "ltrim with empty stdin"
}

# Test: Help flag returns exit code 0
test_help_exit_codes() {
  "$TRIM" --help >/dev/null 2>&1
  assert_exit_code $? 0 "trim --help exits cleanly"

  "$TRIM" -h >/dev/null 2>&1
  assert_exit_code $? 0 "trim -h exits cleanly"

  "$LTRIM" --help >/dev/null 2>&1
  assert_exit_code $? 0 "ltrim --help exits cleanly"

  "$RTRIM" -h >/dev/null 2>&1
  assert_exit_code $? 0 "rtrim -h exits cleanly"
}

# Test: stderr vs stdout separation
test_stderr_stdout_separation() {
  local stdout_file="$TMP_DIR/stdout.txt"
  local stderr_file="$TMP_DIR/stderr.txt"

  # Valid operation - should write to stdout only
  "$TRIM" "  test  " >"$stdout_file" 2>"$stderr_file"

  if [[ -s "$stdout_file" ]] && [[ ! -s "$stderr_file" ]]; then
    echo -e "${GREEN}✓ Test passed${NC}: Valid operation uses stdout only"
  else
    echo -e "${RED}✗ Test failed${NC}: Valid operation should not write to stderr"
    return 1
  fi

  # Invalid operation - should write to stderr only
  "$TRIM" --invalid >"$stdout_file" 2>"$stderr_file" || true

  if [[ -s "$stderr_file" ]]; then
    echo -e "${GREEN}✓ Test passed${NC}: Error messages go to stderr"
  else
    echo -e "${RED}✗ Test failed${NC}: Error messages should go to stderr"
    return 1
  fi
}

# Test: Multiple invalid flags
test_multiple_invalid_flags() {
  local stderr_file="$TMP_DIR/stderr.txt"

  "$TRIM" -x -y -z 2>"$stderr_file" >/dev/null || local exit_code=$?

  if [[ ${exit_code:-0} -ne 0 ]]; then
    echo -e "${GREEN}✓ Exit code test passed${NC}: Multiple invalid flags rejected"
  else
    echo -e "${RED}✗ Exit code test failed${NC}: Should reject multiple invalid flags"
    return 1
  fi
}

# Test: Flag after positional argument
test_flag_after_argument() {
  # Some utilities might accept this, but it's worth testing consistency
  local result1=$("$TRIM" "test" -e 2>/dev/null || echo "FAILED")

  # This tests current behavior - document what happens
  if [[ "$result1" == "FAILED" ]]; then
    echo -e "${GREEN}✓ Test passed${NC}: Flags after arguments are rejected"
  else
    echo -e "${GREEN}✓ Test passed${NC}: Flags after arguments are accepted (result: '$result1')"
  fi
}

# Run all tests
echo "Testing error handling for all trim utilities..."
echo ""

test_trim_invalid_flag
test_ltrim_invalid_flag
test_rtrim_invalid_flag
test_trimall_invalid_flag
test_squeeze_invalid_flag
test_trimv_invalid_varname
test_trimv_valid_varnames
test_success_exit_codes
test_empty_input_exit_code
test_help_exit_codes
test_stderr_stdout_separation
test_multiple_invalid_flags
test_flag_after_argument

echo ""
echo "All error handling tests passed!"
exit 0

#fin
