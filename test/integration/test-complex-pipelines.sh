#!/usr/bin/env bash
# Integration tests for complex pipeline scenarios

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

TRIM="$ROOT_DIR/trim"
LTRIM="$ROOT_DIR/ltrim"
RTRIM="$ROOT_DIR/rtrim"
SQUEEZE="$ROOT_DIR/squeeze"

# Verify utilities exist
for util in "$TRIM" "$LTRIM" "$RTRIM" "$SQUEEZE"; do
  [[ -x "$util" ]] || { echo "Error: $(basename "$util") not found"; exit 1; }
done

echo "Testing complex pipeline scenarios..."

declare -i passed=0 failed=0

# Test 4-stage pipeline
test_four_stage_pipeline() {
  local -- input result expected
  input=$'  c  \n  a  \n  b  \n  a  '
  expected=$'a\nb\nc'

  result=$(echo "$input" | "$TRIM" | sort | uniq)

  if [[ "$result" == "$expected" ]]; then
    echo -e "${GREEN}Test passed${NC}: 4-stage pipeline (trim|sort|uniq)"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: 4-stage pipeline"
    ((++failed))
  fi
}

# Test here-string with trim
test_here_string() {
  local -- result
  result=$("$TRIM" <<< "  hello world  ")

  if [[ "$result" == "hello world" ]]; then
    echo -e "${GREEN}Test passed${NC}: Here-string input"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Here-string input (got: $result)"
    ((++failed))
  fi
}

# Test here-doc with trim
test_here_doc() {
  local -- result expected
  expected=$'line1\nline2\nline3'

  result=$("$TRIM" <<EOF
  line1
  line2
  line3
EOF
)

  if [[ "$result" == "$expected" ]]; then
    echo -e "${GREEN}Test passed${NC}: Here-doc input"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Here-doc input"
    ((++failed))
  fi
}

# Test process substitution
test_process_substitution() {
  local -- result
  result=$(cat < <("$TRIM" "  process sub  "))

  if [[ "$result" == "process sub" ]]; then
    echo -e "${GREEN}Test passed${NC}: Process substitution"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Process substitution (got: $result)"
    ((++failed))
  fi
}

# Test nested command substitution
test_nested_substitution() {
  local -- result
  result=$("$TRIM" "$("$TRIM" "    nested    ")")

  if [[ "$result" == "nested" ]]; then
    echo -e "${GREEN}Test passed${NC}: Nested command substitution"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Nested command substitution (got: $result)"
    ((++failed))
  fi
}

# Test chained trim operations
test_chained_trims() {
  local -- result
  result=$(echo "  chained  " | "$LTRIM" | "$RTRIM")

  if [[ "$result" == "chained" ]]; then
    echo -e "${GREEN}Test passed${NC}: Chained ltrim|rtrim"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Chained ltrim|rtrim (got: $result)"
    ((++failed))
  fi
}

# Test with external tools (grep)
test_with_grep() {
  local -- input result expected
  input=$'  keep  \n  remove  \n  keep  '
  expected=$'keep\nkeep'

  result=$(echo "$input" | "$TRIM" | grep "keep")

  if [[ "$result" == "$expected" ]]; then
    echo -e "${GREEN}Test passed${NC}: Pipeline with grep"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Pipeline with grep"
    ((++failed))
  fi
}

# Test with wc (word count)
test_with_wc() {
  local -- input line_count
  input=$'  one  \n  two  \n  three  '

  line_count=$(echo "$input" | "$TRIM" | wc -l)

  if [[ "$line_count" -eq 3 ]]; then
    echo -e "${GREEN}Test passed${NC}: Pipeline with wc"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Pipeline with wc (got: $line_count lines)"
    ((++failed))
  fi
}

# Test squeeze then trim
test_squeeze_then_trim() {
  local -- result
  result=$(echo "  multiple    spaces  " | "$SQUEEZE" | "$TRIM")

  if [[ "$result" == "multiple spaces" ]]; then
    echo -e "${GREEN}Test passed${NC}: squeeze|trim pipeline"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: squeeze|trim (got: $result)"
    ((++failed))
  fi
}

# Test subshell preservation
test_subshell() {
  local -- result
  result=$( (echo "  subshell  " | "$TRIM") )

  if [[ "$result" == "subshell" ]]; then
    echo -e "${GREEN}Test passed${NC}: Subshell execution"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: Subshell execution (got: $result)"
    ((++failed))
  fi
}

# Run all tests
test_four_stage_pipeline
test_here_string
test_here_doc
test_process_substitution
test_nested_substitution
test_chained_trims
test_with_grep
test_with_wc
test_squeeze_then_trim
test_subshell

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All complex pipeline tests passed!" && exit 0
echo "Complex pipeline tests FAILED" && exit 1

#fin
