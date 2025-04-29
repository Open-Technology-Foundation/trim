# Trim Utilities Test Suite

A comprehensive test framework for validating the Bash string trim utilities.

## Overview

This test suite ensures the correctness and reliability of all trim utilities through unit tests for individual functions and integration tests for combined usage scenarios. Tests cover basic functionality, edge cases, input/output methods, and command-line options.

## Test Directory Structure

```
./test/
├── run-tests.sh            # Main test runner script
├── utils.sh                # Common test utilities and assertion functions
├── fixtures/               # Test data files
│   ├── input/              # Input test files with various content types
│   ├── expected/           # Expected output files for verification
│   └── tmp/                # Temporary files created during test execution
├── unit/                   # Individual utility tests
│   ├── test-trim.sh        # Tests for trim utility
│   ├── test-ltrim.sh       # Tests for ltrim utility
│   ├── test-rtrim.sh       # Tests for rtrim utility
│   ├── test-trimv.sh       # Tests for trimv utility
│   └── test-trimall.sh     # Tests for trimall utility
└── integration/            # Tests for combined usage scenarios
    ├── test-pipes.sh       # Tests for piping between utilities
    └── test-sourced.sh     # Tests for utilities when sourced into scripts
```

## Running the Tests

The test suite supports running all tests or specific categories:

```bash
# Run the complete test suite
./test/run-tests.sh

# Run only unit tests
./test/run-tests.sh unit

# Run only integration tests
./test/run-tests.sh integration
```

## Test Coverage

The test suite provides comprehensive coverage across multiple dimensions:

1. **Core Functionality**
   - Basic whitespace trimming operations
   - String and stream processing
   - Command argument handling

2. **Edge Cases**
   - Empty strings and input
   - Whitespace-only content
   - Mixed whitespace characters
   - Multiline content

3. **Features**
   - Escape sequence processing with `-e` flag
   - Variable assignment with `trimv -n`
   - Stream processing via stdin/stdout

4. **Integration Scenarios**
   - Pipeline usage between utilities
   - Sourced function behavior
   - Combined operations

## Test Utilities

The `utils.sh` script provides helper functions for all tests:

| Function | Purpose |
|----------|---------|
| `assert_equals` | Compare two strings and report success/failure |
| `assert_file_equals` | Compare contents of two files with diff reporting |
| `create_temp_file` | Generate temporary file with specified content |
| `create_temp_multiline_file` | Create multiline temp files from stdin |
| `cleanup_temp_files` | Remove temporary test artifacts |

## Adding New Tests

To extend the test coverage:

### Creating a New Unit Test

1. Create a new test script in the `unit/` directory
2. Follow the existing pattern:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   # Source test utilities
   TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
   source "$TEST_DIR/../utils.sh"
   
   # Define test functions
   test_feature_one() {
     # Test implementation
     assert_equals "actual" "expected" "Description"
   }
   
   # Run tests
   test_feature_one
   # Additional tests...
   
   echo "All tests passed!"
   exit 0
   ```
3. Make it executable: `chmod +x test/unit/test-newfeature.sh`

### Creating a New Integration Test

1. Create a script in the `integration/` directory
2. Test interactions between multiple utilities
3. Focus on real-world usage scenarios

### Adding Test Fixtures

For tests requiring input/output files:

1. Add input files to `fixtures/input/`
2. Create corresponding expected output in `fixtures/expected/`
3. Use clear naming that reflects the test purpose
4. Ensure all fixture files end with a newline

## Test Maintenance

When modifying the utilities:

1. Run the full test suite to ensure changes don't break existing functionality
2. Add new tests for any added features or fixed bugs
3. Update expected output files if the intended behavior changes

#fin