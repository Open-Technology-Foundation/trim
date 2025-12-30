#!/usr/bin/env bash
# Security tests for command injection prevention

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source trimv for function testing
source "$ROOT_DIR/trimv.bash"

echo "Testing security: command injection prevention..."

# Track test results
declare -i passed=0 failed=0

# Test that a variable name is rejected
run_rejected_test() {
  local -- varname="$1"
  local -- description="$2"

  if trimv -n "$varname" "test" 2>/dev/null; then
    echo -e "${RED}✗ SECURITY FAIL${NC}: $description"
    ((++failed))
  else
    echo -e "${GREEN}✓ Test passed${NC}: $description"
    ((++passed))
  fi
}

# Test that a variable name is accepted
run_accepted_test() {
  local -- varname="$1"
  local -- description="$2"

  if trimv -n "$varname" "  test  " 2>/dev/null; then
    echo -e "${GREEN}✓ Test passed${NC}: $description"
    ((++passed))
  else
    echo -e "${RED}✗ Test failed${NC}: $description"
    ((++failed))
  fi
}

echo "--- Injection Prevention ---"

# Command injection patterns that must be rejected
run_rejected_test 'var; echo x' "Semicolon injection"
run_rejected_test 'var|cat' "Pipe injection"
run_rejected_test 'var&' "Background operator"
run_rejected_test 'var>' "Redirect >"
run_rejected_test 'var<' "Redirect <"
run_rejected_test 'var name' "Space in name"
run_rejected_test '../path' "Path traversal"
run_rejected_test '/path' "Absolute path"
run_rejected_test 'var*' "Glob asterisk"
run_rejected_test 'var?' "Glob question"
run_rejected_test '123var' "Starts with number"
run_rejected_test '-var' "Starts with dash"
# Note: Empty name '' defaults to 'TRIM' via ${2:-TRIM}, which is safe behavior

echo "--- Valid Names ---"

# Valid variable names
run_accepted_test 'myvar' "Simple lowercase"
run_accepted_test 'MYVAR' "Simple uppercase"
run_accepted_test 'my_var' "With underscore"
run_accepted_test '_private' "Leading underscore"
run_accepted_test 'var123' "With numbers"
run_accepted_test '_' "Single underscore"
run_accepted_test 'a' "Single char"

echo "--- Input Content ---"

# Test malicious content in input (should be treated as literal)
local_result=$(trimv '  $(echo hacked)  ')
if [[ "$local_result" == '$(echo hacked)' ]]; then
  echo -e "${GREEN}✓ Test passed${NC}: Command substitution literal"
  ((++passed))
else
  echo -e "${RED}✗ Test failed${NC}: Command substitution"
  ((++failed))
fi

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All security tests passed!" && exit 0
echo "Security tests FAILED" && exit 1

#fin
