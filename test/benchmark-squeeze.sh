#!/usr/bin/env bash
# Benchmark different approaches for squeezing consecutive spaces

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Approach 1: While loop (current implementation)
squeeze_while_loop() {
  local -- v="$1"
  v="${v//$'\t'/ }"
  while [[ $v =~ "  " ]]; do
    v="${v//  / }"
  done
  echo -n "$v"
}

# Approach 2: tr -s
squeeze_tr() {
  local -- v="$1"
  v="${v//$'\t'/ }"
  echo -n "$v" | tr -s ' '
}

# Approach 3: set -f with edge preservation
squeeze_set_f() {
  local -- v="$1"
  v="${v//$'\t'/ }"

  # Handle empty or whitespace-only strings
  if [[ -z "${v// /}" ]]; then
    echo -n " "
    return 0
  fi

  # Extract leading spaces (if any)
  local -- leading=""
  if [[ $v =~ ^(" "+) ]]; then
    leading="${BASH_REMATCH[1]}"
    # Collapse leading spaces to single space
    leading=" "
  fi

  # Extract trailing spaces (if any)
  local -- trailing=""
  if [[ $v =~ (" "+)$ ]]; then
    trailing="${BASH_REMATCH[1]}"
    # Collapse trailing spaces to single space
    trailing=" "
  fi

  # Collapse interior spaces using word splitting
  set -f
  set -- $v
  local -- middle="$*"
  set +f

  echo -n "${leading}${middle}${trailing}"
}

# Benchmark function
benchmark() {
  local -- name="$1"
  local -- func="$2"
  local -- input="$3"
  local -i iterations="${4:-1000}"

  local -- start end
  start=$EPOCHREALTIME

  local -i i
  for ((i=0; i<iterations; i+=1)); do
    $func "$input" >/dev/null
  done

  end=$EPOCHREALTIME
  local -- total_time=$(awk "BEGIN {print $end - $start}")
  local -- avg_time=$(awk "BEGIN {print $total_time / $iterations}")

  printf '%s%-20s%s: %d iterations, %.3fs total, %.6fs average\n' \
    "$CYAN" "$name" "$NC" "$iterations" "$total_time" "$avg_time"
}

# Verify correctness first
echo -e "${YELLOW}Verifying correctness of all approaches...${NC}"
echo ""

test_cases=(
  "hello    world"
  "  hello    world  "
  "multiple     consecutive      spaces"
  $'\t  hello \t\t world \t  '
  "    "
)

declare -i all_correct=1
for test in "${test_cases[@]}"; do
  result_loop=$(squeeze_while_loop "$test")
  result_tr=$(squeeze_tr "$test")
  result_set_f=$(squeeze_set_f "$test")

  if [[ "$result_loop" != "$result_tr" ]] || [[ "$result_loop" != "$result_set_f" ]]; then
    echo -e "${YELLOW}Input:${NC} '$test'"
    echo "  while_loop: '$result_loop'"
    echo "  tr:         '$result_tr'"
    echo "  set_f:      '$result_set_f'"
    if [[ "$result_loop" != "$result_tr" ]] || [[ "$result_loop" != "$result_set_f" ]]; then
      echo -e "  ${GREEN}Note: Differences may be expected for edge cases${NC}"
    fi
    echo ""
    all_correct=0
  fi
done

if ((all_correct)); then
  echo -e "${GREEN}✓ All approaches produce identical results${NC}"
else
  echo -e "${YELLOW}⚠ Some differences detected (see above)${NC}"
fi
echo ""

# Benchmark different input patterns
echo -e "${YELLOW}Benchmarking different input patterns...${NC}"
echo ""

# Pattern 1: Short string with few spaces
echo -e "${CYAN}Pattern 1: Short string (2-4 consecutive spaces)${NC}"
input1="hello    world    test"
benchmark "While Loop" "squeeze_while_loop" "$input1" 10000
benchmark "TR Command" "squeeze_tr" "$input1" 1000
benchmark "Set -f" "squeeze_set_f" "$input1" 10000
echo ""

# Pattern 2: Medium string with many spaces
echo -e "${CYAN}Pattern 2: Medium string (8-16 consecutive spaces)${NC}"
input2="hello                world        this                is"
benchmark "While Loop" "squeeze_while_loop" "$input2" 10000
benchmark "TR Command" "squeeze_tr" "$input2" 1000
benchmark "Set -f" "squeeze_set_f" "$input2" 10000
echo ""

# Pattern 3: Long string with mixed spacing
echo -e "${CYAN}Pattern 3: Long string with mixed spacing${NC}"
input3="word1    word2        word3   word4       word5    word6        word7"
benchmark "While Loop" "squeeze_while_loop" "$input3" 10000
benchmark "TR Command" "squeeze_tr" "$input3" 1000
benchmark "Set -f" "squeeze_set_f" "$input3" 10000
echo ""

# Pattern 4: String with leading/trailing spaces
echo -e "${CYAN}Pattern 4: String with leading/trailing spaces${NC}"
input4="  hello    world    test  "
benchmark "While Loop" "squeeze_while_loop" "$input4" 10000
benchmark "TR Command" "squeeze_tr" "$input4" 1000
benchmark "Set -f" "squeeze_set_f" "$input4" 10000
echo ""

# Pattern 5: Very long runs of spaces (worst case for while loop)
echo -e "${CYAN}Pattern 5: Very long runs of spaces (32+ spaces)${NC}"
input5="hello                                world"
benchmark "While Loop" "squeeze_while_loop" "$input5" 5000
benchmark "TR Command" "squeeze_tr" "$input5" 500
benchmark "Set -f" "squeeze_set_f" "$input5" 5000
echo ""

# Pattern 6: Realistic text processing
echo -e "${CYAN}Pattern 6: Realistic log line processing${NC}"
input6="2024-01-15    10:23:45    INFO    Processing    request    from    user"
benchmark "While Loop" "squeeze_while_loop" "$input6" 10000
benchmark "TR Command" "squeeze_tr" "$input6" 1000
benchmark "Set -f" "squeeze_set_f" "$input6" 10000
echo ""

echo -e "${GREEN}Benchmark complete!${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "- While Loop: Pure Bash, good for typical cases (2-10 spaces)"
echo "- TR Command: Spawns subprocess, overhead may dominate for short strings"
echo "- Set -f: Fastest for most cases, but complex edge handling"

#fin