#!/usr/bin/env bash
# Test utility functions for trim utilities

set -euo pipefail

# Test directory paths
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
TMP_DIR="$FIXTURES_DIR/tmp"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Ensure tmp directory exists
mkdir -p "$TMP_DIR"

# Function to assert equality
assert_equals() {
  local actual="$1"
  local expected="$2"
  local message="${3:-}"
  
  if [[ "$actual" == "$expected" ]]; then
    echo -e "${GREEN}✓ Test passed${NC}${message:+: $message}"
    return 0
  else
    echo -e "${RED}✗ Test failed${NC}${message:+: $message}"
    echo -e "Expected: '$expected'"
    echo -e "Actual:   '$actual'"
    return 1
  fi
}

# Function to assert file equality
assert_file_equals() {
  local actual_file="$1"
  local expected_file="$2"
  local message="${3:-}"
  
  if diff -q "$actual_file" "$expected_file" > /dev/null; then
    echo -e "${GREEN}✓ File test passed${NC}${message:+: $message}"
    return 0
  else
    echo -e "${RED}✗ File test failed${NC}${message:+: $message}"
    echo -e "Files differ:"
    diff "$expected_file" "$actual_file"
    return 1
  fi
}

# Function to create a temporary file with content
create_temp_file() {
  local content="$1"
  local temp_file="$TMP_DIR/test_$(date +%s%N).txt"
  
  echo -n "$content" > "$temp_file"
  echo "$temp_file"
}

# Function to create a temporary multiline file
create_temp_multiline_file() {
  local temp_file="$TMP_DIR/test_$(date +%s%N).txt"
  cat > "$temp_file"
  echo "$temp_file"
}

# Function to clean up temporary files
cleanup_temp_files() {
  rm -f "$TMP_DIR"/*
}

# Register cleanup on script exit
trap cleanup_temp_files EXIT

#fin