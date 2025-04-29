#!/bin/bash
# Test script for trimv piping
TRIMV="/ai/scripts/lib/str/trim/trimv"

# Initialize variable
test_var=""

# Pipe to trimv
echo "  hello from pipeline  " | $TRIMV -n test_var

# Output result
echo "Variable value: '$test_var'"