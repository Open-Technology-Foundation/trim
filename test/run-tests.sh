#!/usr/bin/env bash
# Main test runner for trim utilities

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR"
FIXTURES_DIR="$TEST_DIR/fixtures"
UNIT_DIR="$TEST_DIR/unit"
INTEGRATION_DIR="$TEST_DIR/integration"
SECURITY_DIR="$TEST_DIR/security"
STRESS_DIR="$TEST_DIR/stress"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test counters
declare -i total_tests=0
declare -i passed_tests=0
declare -i failed_tests=0

# Function to run a test script
run_test() {
  local -- test_script="$1"
  local -- test_name
  test_name="$(basename "$test_script" .sh)"

  echo -e "${YELLOW}Running $test_name...${NC}"

  # Run the test script and capture output and exit code
  if "$test_script"; then
    ((++passed_tests))
    echo -e "${GREEN}✓ $test_name passed${NC}"
  else
    ((++failed_tests))
    echo -e "${RED}✗ $test_name failed${NC}"
  fi

  ((++total_tests))
  echo ""
}

# Run all unit tests
run_unit_tests() {
  echo -e "${YELLOW}Running unit tests...${NC}"
  for test in "$UNIT_DIR"/test-*.sh; do
    if [[ -x "$test" ]]; then
      run_test "$test"
    else
      echo -e "${YELLOW}Warning: $test is not executable, skipping${NC}"
    fi
  done
}

# Run all integration tests
run_integration_tests() {
  echo -e "${YELLOW}Running integration tests...${NC}"
  for test in "$INTEGRATION_DIR"/test-*.sh; do
    if [[ -x "$test" ]]; then
      run_test "$test"
    else
      echo -e "${YELLOW}Warning: $test is not executable, skipping${NC}"
    fi
  done
}

# Run all security tests
run_security_tests() {
  if [[ -d "$SECURITY_DIR" ]]; then
    echo -e "${YELLOW}Running security tests...${NC}"
    for test in "$SECURITY_DIR"/test-*.sh; do
      if [[ -x "$test" ]]; then
        run_test "$test"
      else
        echo -e "${YELLOW}Warning: $test is not executable, skipping${NC}"
      fi
    done
  fi
}

# Run all stress tests
run_stress_tests() {
  if [[ -d "$STRESS_DIR" ]]; then
    echo -e "${YELLOW}Running stress tests...${NC}"
    for test in "$STRESS_DIR"/test-*.sh; do
      if [[ -x "$test" ]]; then
        run_test "$test"
      else
        echo -e "${YELLOW}Warning: $test is not executable, skipping${NC}"
      fi
    done
  fi
}

# Run all tests
run_all_tests() {
  run_unit_tests
  run_integration_tests
  run_security_tests
  run_stress_tests
}

# Print test summary
print_summary() {
  echo -e "${YELLOW}Test Summary:${NC}"
  echo -e "Total tests: $total_tests"
  echo -e "${GREEN}Passed: $passed_tests${NC}"
  if ((failed_tests > 0)); then
    echo -e "${RED}Failed: $failed_tests${NC}"
    exit 1
  else
    echo -e "All tests passed!"
    exit 0
  fi
}

# Process command line arguments
if [[ $# -eq 0 ]]; then
  run_all_tests
else
  case "$1" in
    unit)
      run_unit_tests
      ;;
    integration)
      run_integration_tests
      ;;
    security)
      run_security_tests
      ;;
    stress)
      run_stress_tests
      ;;
    *)
      echo "Unknown test category: $1"
      echo "Usage: $0 [unit|integration|security|stress]"
      exit 1
      ;;
  esac
fi

# Print test summary
print_summary

#fin