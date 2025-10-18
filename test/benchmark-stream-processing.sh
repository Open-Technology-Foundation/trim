#!/usr/bin/env bash
# Benchmark: Stream processing comparison
#
# Compares performance of:
#   1. trim < input           - Direct line-by-line processing
#   2. trimv < input          - Direct line-by-line processing (same as trim)
#   3. trimv -n var < input   - Uses temp file (expensive!)

set -euo pipefail

# Test directory
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Source the utilities
# shellcheck disable=SC1091
source "$ROOT_DIR/trim.bash"
# shellcheck disable=SC1091
source "$ROOT_DIR/trimv.bash"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Verify timer command exists
if ! command -v timer &>/dev/null; then
  echo "Error: 'timer' command not found. Please install it first." >&2
  exit 1
fi

echo -e "${BOLD}${CYAN}=== Stream Processing Benchmark ===${NC}"
echo ""

# Create test data files
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Create small test file (100 lines)
{
  for ((i=0; i<100; i+=1)); do
    echo "  Line $i with some text and trailing spaces  "
  done
} > "$TMPDIR/small.txt"

# Create medium test file (1000 lines)
{
  for ((i=0; i<1000; i+=1)); do
    echo "  Line $i with some text and trailing spaces  "
  done
} > "$TMPDIR/medium.txt"

# Create large test file (10000 lines)
{
  for ((i=0; i<10000; i+=1)); do
    echo "  Line $i with some text and trailing spaces  "
  done
} > "$TMPDIR/large.txt"

echo -e "${YELLOW}Test Data Created:${NC}"
echo "  Small:  100 lines"
echo "  Medium: 1,000 lines"
echo "  Large:  10,000 lines"
echo ""

# Test 1: Small file (100 lines)
echo -e "${BOLD}${CYAN}Test 1: Small file (100 lines)${NC}"
echo ""

result1=$(timer -f bash -c "
  source '$ROOT_DIR/trim.bash'
  for ((i=0; i<100; i+=1)); do
    trim < '$TMPDIR/small.txt' >/dev/null
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result2=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  for ((i=0; i<100; i+=1)); do
    trimv < '$TMPDIR/small.txt' >/dev/null
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result3=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  for ((i=0; i<100; i+=1)); do
    trimv -n result < '$TMPDIR/small.txt'
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

printf "  %-30s %s\n" "trim < file:" "$result1"
printf "  %-30s %s\n" "trimv < file:" "$result2"
printf "  %-30s %s (uses temp file!)\n" "trimv -n var < file:" "$result3"
echo ""

# Test 2: Medium file (1000 lines)
echo -e "${BOLD}${CYAN}Test 2: Medium file (1,000 lines)${NC}"
echo ""

result1=$(timer -f bash -c "
  source '$ROOT_DIR/trim.bash'
  for ((i=0; i<10; i+=1)); do
    trim < '$TMPDIR/medium.txt' >/dev/null
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result2=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  for ((i=0; i<10; i+=1)); do
    trimv < '$TMPDIR/medium.txt' >/dev/null
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result3=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  for ((i=0; i<10; i+=1)); do
    trimv -n result < '$TMPDIR/medium.txt'
  done
" 2>&1 | grep "timer:" | sed 's/# timer: //')

printf "  %-30s %s\n" "trim < file:" "$result1"
printf "  %-30s %s\n" "trimv < file:" "$result2"
printf "  %-30s %s (uses temp file!)\n" "trimv -n var < file:" "$result3"
echo ""

# Test 3: Large file (10000 lines)
echo -e "${BOLD}${CYAN}Test 3: Large file (10,000 lines)${NC}"
echo ""

result1=$(timer -f bash -c "
  source '$ROOT_DIR/trim.bash'
  trim < '$TMPDIR/large.txt' >/dev/null
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result2=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  trimv < '$TMPDIR/large.txt' >/dev/null
" 2>&1 | grep "timer:" | sed 's/# timer: //')

result3=$(timer -f bash -c "
  source '$ROOT_DIR/trimv.bash'
  trimv -n result < '$TMPDIR/large.txt'
" 2>&1 | grep "timer:" | sed 's/# timer: //')

printf "  %-30s %s\n" "trim < file:" "$result1"
printf "  %-30s %s\n" "trimv < file:" "$result2"
printf "  %-30s %s (uses temp file!)\n" "trimv -n var < file:" "$result3"
echo ""

# Verify correctness
echo -e "${YELLOW}Verifying correctness...${NC}"
trim_result=$(trim < "$TMPDIR/small.txt")
trimv_result=$(trimv < "$TMPDIR/small.txt")
trimv -n var_result < "$TMPDIR/small.txt"

if [[ "$trim_result" == "$trimv_result" ]] && [[ "$trim_result" == "$var_result" ]]; then
  echo -e "${GREEN}✓ All methods produce identical output${NC}"
else
  echo -e "${YELLOW}⚠ Output mismatch detected${NC}"
fi
echo ""

# Summary
echo -e "${BOLD}${GREEN}=== Summary ===${NC}"
echo ""
echo -e "${YELLOW}Stream Processing Modes:${NC}"
echo ""
echo "  1. trim < file"
echo "     • Processes line-by-line directly to stdout"
echo "     • Fast and efficient"
echo "     • Use for: Piping data through filters"
echo ""
echo "  2. trimv < file (without -n)"
echo "     • Identical to trim for stream processing"
echo "     • Same performance characteristics"
echo "     • Use for: Alternative syntax, same behavior"
echo ""
echo "  3. trimv -n var < file"
echo "     • Creates temp file with mktemp"
echo "     • Writes all lines to temp file"
echo "     • Reads entire file into variable"
echo "     • Deletes temp file"
echo "     • Much slower due to file I/O overhead"
echo "     • Use for: Capturing multi-line output in a variable"
echo ""
echo -e "${YELLOW}Key Takeaways:${NC}"
echo "  • For stream processing to stdout: Use 'trim' or 'trimv' (equivalent)"
echo "  • For capturing streams in variables: Use 'trimv -n var' but expect overhead"
echo "  • The temp file approach in trimv -n is necessary for variable assignment"
echo "  • For large streams, avoid 'trimv -n' if possible - use direct piping instead"
echo ""
echo -e "${YELLOW}Example Usage:${NC}"
echo "  # Fast: Process and output directly"
echo "  cat logfile.txt | trim > cleaned.txt"
echo ""
echo "  # Slow: Capture in variable (creates temp file)"
echo "  source trimv.bash"
echo "  trimv -n content < logfile.txt"
echo "  echo \"\$content\""
echo ""

#fin
