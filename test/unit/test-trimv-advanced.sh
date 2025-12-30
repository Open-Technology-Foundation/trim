#!/usr/bin/env bash
# Advanced unit tests for trimv edge cases

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source trimv for function testing
source "$ROOT_DIR/trimv.bash"

echo "Testing trimv advanced scenarios..."

declare -i passed=0 failed=0

# Test default variable name (TRIM)
test_default_varname() {
  unset TRIM 2>/dev/null || true
  trimv -n TRIM "  hello  "

  if [[ "${TRIM:-}" == "hello" ]]; then
    echo -e "${GREEN}Test passed${NC}: Default variable TRIM"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Default variable TRIM (got: ${TRIM:-<empty>})"
    ((++failed))
  fi
}

# Test empty -n argument defaults to TRIM
test_empty_n_defaults() {
  unset TRIM 2>/dev/null || true
  trimv -n '' "  world  "

  if [[ "${TRIM:-}" == "world" ]]; then
    echo -e "${GREEN}Test passed${NC}: Empty -n defaults to TRIM"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Empty -n defaults to TRIM"
    ((++failed))
  fi
}

# Test overwriting existing variable
test_overwrite_variable() {
  local -- MYVAR="original"
  trimv -n MYVAR "  replaced  "

  if [[ "$MYVAR" == "replaced" ]]; then
    echo -e "${GREEN}Test passed${NC}: Overwrite existing variable"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Overwrite existing variable (got: $MYVAR)"
    ((++failed))
  fi
}

# Test underscore-only variable names
# Note: Single underscore _ is special in Bash, so we test __ and ___
test_underscore_names() {
  local -- __=""
  local -- ___=""

  trimv -n __ "  two  "
  trimv -n ___ "  three  "

  if [[ "$__" == "two" && "$___" == "three" ]]; then
    echo -e "${GREEN}Test passed${NC}: Underscore-only variable names"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Underscore-only names (__=$__, ___=$___)"
    ((++failed))
  fi
}

# Test variable name with numbers
test_varname_with_numbers() {
  local -- var123=""
  local -- _123var=""

  trimv -n var123 "  num1  "
  trimv -n _123var "  num2  "

  if [[ "$var123" == "num1" && "$_123var" == "num2" ]]; then
    echo -e "${GREEN}Test passed${NC}: Variable names with numbers"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Variable names with numbers"
    ((++failed))
  fi
}

# Test -e flag with -n flag combined
test_e_and_n_combined() {
  local -- RESULT=""
  trimv -e -n RESULT '\t  hello  \t'

  if [[ "$RESULT" == "hello" ]]; then
    echo -e "${GREEN}Test passed${NC}: -e and -n combined"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: -e and -n combined (got: ${RESULT@Q})"
    ((++failed))
  fi
}

# Test trimv output mode (no -n flag)
test_output_mode() {
  local -- result
  result=$(trimv "  output mode  ")

  if [[ "$result" == "output mode" ]]; then
    echo -e "${GREEN}Test passed${NC}: Output mode (no -n)"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Output mode (got: $result)"
    ((++failed))
  fi
}

# Test stdin with -n flag using here-string (avoids subshell issue)
test_stdin_with_n() {
  local -- STDIN_RESULT=""
  trimv -n STDIN_RESULT <<< "  from stdin  "

  if [[ "$STDIN_RESULT" == "from stdin" ]]; then
    echo -e "${GREEN}Test passed${NC}: stdin with -n (here-string)"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: stdin with -n (got: $STDIN_RESULT)"
    ((++failed))
  fi
}

# Test multiline stdin with -n using here-doc
test_multiline_stdin_n() {
  local -- MULTI=""
  trimv -n MULTI <<EOF
  line1
  line2
EOF

  local -- expected=$'line1\nline2'
  if [[ "$MULTI" == "$expected" ]]; then
    echo -e "${GREEN}Test passed${NC}: Multiline stdin with -n"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Multiline stdin with -n (got: ${MULTI@Q})"
    ((++failed))
  fi
}

# Test preserving internal whitespace
test_internal_whitespace() {
  local -- RESULT=""
  trimv -n RESULT "  hello   world  "

  if [[ "$RESULT" == "hello   world" ]]; then
    echo -e "${GREEN}Test passed${NC}: Internal whitespace preserved"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Internal whitespace (got: $RESULT)"
    ((++failed))
  fi
}

# Test empty input
test_empty_input() {
  local -- RESULT="nonempty"
  trimv -n RESULT ""

  if [[ -z "$RESULT" ]]; then
    echo -e "${GREEN}Test passed${NC}: Empty input produces empty result"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Empty input (got: $RESULT)"
    ((++failed))
  fi
}

# Test whitespace-only input
test_whitespace_only() {
  local -- RESULT="nonempty"
  trimv -n RESULT "     "

  if [[ -z "$RESULT" ]]; then
    echo -e "${GREEN}Test passed${NC}: Whitespace-only input"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Whitespace-only (got: $RESULT)"
    ((++failed))
  fi
}

# Run all tests
test_default_varname
test_empty_n_defaults
test_overwrite_variable
test_underscore_names
test_varname_with_numbers
test_e_and_n_combined
test_output_mode
test_stdin_with_n
test_multiline_stdin_n
test_internal_whitespace
test_empty_input
test_whitespace_only

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All trimv advanced tests passed!" && exit 0
echo "Trimv advanced tests FAILED" && exit 1

#fin
