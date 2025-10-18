# Test Coverage Analysis
## Current vs. Potential Test Coverage

### Currently Tested ✓

| Category | Coverage |
|----------|----------|
| Basic functionality | ✓ All utilities |
| stdin/stdout processing | ✓ Files and pipes |
| Escape sequences (-e flag) | ✓ Basic cases |
| Edge cases | ✓ Empty, whitespace-only |
| Integration | ✓ Pipes, sourced functions |
| trimv variable assignment | ✓ Basic -n flag |
| trimv invalid var name | ✓ One test case |

**Total Test Assertions: ~91**

---

## Missing Coverage ⚠️

### 1. Error Handling & Exit Codes
**Impact: High** | **Complexity: Low**

- [ ] Invalid flags (`trim --invalid`, `trim -x`)
- [ ] Multiple conflicting flags
- [ ] Correct exit codes for success (0) and failure (non-zero)
- [ ] stderr vs stdout separation
- [ ] Handling of interrupts (Ctrl+C)

**Example test:**
```bash
# Should fail with exit code 22 (EINVAL)
trim --invalid-flag 2>/dev/null
assert_exit_code $? 22 "Invalid flag returns error code"
```

---

### 2. Help Flag Testing
**Impact: Medium** | **Complexity: Low**

- [ ] `--help` flag displays help
- [ ] `-h` flag displays help
- [ ] Help works with other flags (`trim -e --help`)
- [ ] Help exits with code 0
- [ ] Help output format consistency

---

### 3. Unicode & Special Characters
**Impact: High** | **Complexity: Medium**

- [ ] UTF-8 multi-byte characters (emoji, Chinese, Arabic)
- [ ] Right-to-left text
- [ ] Combining characters
- [ ] Zero-width characters (U+200B, U+FEFF)
- [ ] Non-breaking spaces (U+00A0)
- [ ] Other Unicode whitespace (U+2000 - U+200A)

**Example test:**
```bash
# Emoji should be preserved
input="  👋 Hello 🌍  "
expected="👋 Hello 🌍"
assert_equals "$(trim "$input")" "$expected"

# Non-breaking space (should it be trimmed?)
input=$'\u00A0hello\u00A0'  # Non-breaking spaces
# Current behavior: not trimmed ([:blank:] = tab/space only)
```

---

### 4. Line Ending Variations
**Impact: Medium** | **Complexity: Low**

- [ ] Windows CRLF (`\r\n`)
- [ ] Mac Classic CR (`\r`)
- [ ] Unix LF (`\n`)
- [ ] Mixed line endings
- [ ] Files without trailing newline

**Example test:**
```bash
# Windows-style line endings
echo -e "  line1  \r\n  line2  \r\n" | trim
# Should preserve \r or strip it?
```

---

### 5. Binary Safety & Null Bytes
**Impact: Medium** | **Complexity: Medium**

- [ ] Strings with embedded null bytes (`\0`)
- [ ] Binary data detection
- [ ] Non-text file handling
- [ ] Preserving binary data when present

---

### 6. Stress Testing & Performance
**Impact: Medium** | **Complexity: Low**

- [ ] Very long strings (1MB+)
- [ ] Very long lines (100K+ chars)
- [ ] Many small operations (10K+ iterations)
- [ ] Large file processing (100MB+)
- [ ] Memory usage limits
- [ ] Stack depth limits (recursion safety)

**Example test:**
```bash
# 1MB string of spaces
large_string=$(printf ' %.0s' {1..1048576})
result=$(trim "$large_string")
assert_equals "$result" ""
```

---

### 7. trimv Advanced Variable Tests
**Impact: High** | **Complexity: Low**

- [ ] Variable name with underscores (`my_var_name`)
- [ ] Variable name starting with underscore (`_private`)
- [ ] Reserved Bash words (`if`, `then`, `done`, etc.)
- [ ] Variables with dashes (should fail)
- [ ] Variables with special chars (should fail)
- [ ] Variables with numbers in middle (`var123name`)
- [ ] Empty variable name (`trimv -n ""`)
- [ ] Default variable name when -n has no arg
- [ ] Overwriting existing variables
- [ ] readonly variables (should fail)

**Example test:**
```bash
# Reserved words should work (they're valid var names)
trimv -n if "  test  "
assert_equals "$if" "test"

# Should fail gracefully
readonly CONST="original"
trimv -n CONST "  new  " 2>/dev/null
assert_equals $? 1  # Should return error
assert_equals "$CONST" "original"  # Should be unchanged
```

---

### 8. Flag Combination Testing
**Impact: Medium** | **Complexity: Low**

- [ ] `-e` before other flags
- [ ] `-e` after other flags
- [ ] Multiple `-e` flags (should work)
- [ ] `-n` with `-e` in different orders
- [ ] Repeated flags behavior

**Example test:**
```bash
# These should all work identically
trimv -e -n var "\\t test \\t"
trimv -n var -e "\\t test \\t"
```

---

### 9. Security Testing
**Impact: High** | **Complexity: Medium**

- [ ] Command injection attempts in variable names
- [ ] Shell metacharacters in input
- [ ] Path traversal in variable names
- [ ] Code injection via eval (trimv)
- [ ] Malicious escape sequences

**Example test:**
```bash
# Should not execute commands
trimv -n 'var; rm -rf /' "test" 2>/dev/null
assert_exit_code $? 1  # Should fail validation

# Test eval safety
trimv -n result '$(echo hacked)'
# Variable name should be rejected, not executed
```

---

### 10. Execution Mode Testing
**Impact: Low** | **Complexity: Low**

- [ ] Execution via symlink
- [ ] Execution via `bash trim.bash`
- [ ] Execution via `./trim` (no .bash extension)
- [ ] Sourcing multiple times
- [ ] Function availability after sourcing

---

### 11. Platform Compatibility
**Impact: Low** | **Complexity: High**

- [ ] Different Bash versions (4.x, 5.x)
- [ ] macOS vs Linux differences
- [ ] BSD sed/grep compatibility
- [ ] Locale variations (LANG, LC_ALL)

---

### 12. Complex Integration Scenarios
**Impact: Medium** | **Complexity: Low**

- [ ] Triple/quadruple piping
- [ ] Using in subshells
- [ ] Process substitution
- [ ] Command substitution edge cases
- [ ] Here-documents and here-strings

**Example test:**
```bash
# Complex pipeline
echo "  test  " | trim | ltrim | rtrim | trimall
result=$(echo "  a    b  " | trim | squeeze | trimall)
assert_equals "$result" "a b"
```

---

### 13. Documentation Validation
**Impact: Low** | **Complexity: Low**

- [ ] All examples in README work
- [ ] Help text matches actual behavior
- [ ] Man page examples (if exists)
- [ ] CLAUDE.md examples work

---

## Priority Matrix

### High Priority (Implement First)
1. **Error handling & exit codes** - Critical for proper usage
2. **Unicode support** - Modern text processing requirement
3. **trimv security** - eval usage needs validation
4. **trimv variable edge cases** - Core functionality

### Medium Priority (Implement Second)
1. Line ending variations
2. Stress testing
3. Flag combinations
4. Complex integration scenarios

### Low Priority (Nice to Have)
1. Platform compatibility
2. Execution mode testing
3. Documentation validation

---

## Estimated Test Expansion

| Current | Potential | Increase |
|---------|-----------|----------|
| ~91 assertions | ~350+ assertions | **~3.8x** |
| 8 test files | 15+ test files | **~2x** |
| 2 categories | 5 categories | **2.5x** |

---

## Proposed New Test Files

```
test/
├── unit/
│   ├── test-error-handling.sh       # NEW: Exit codes, invalid flags
│   ├── test-unicode.sh               # NEW: UTF-8, special chars
│   ├── test-help-flags.sh            # NEW: Help output validation
│   └── test-trimv-advanced.sh        # NEW: Variable name edge cases
├── integration/
│   ├── test-complex-pipelines.sh     # NEW: Advanced piping
│   └── test-line-endings.sh          # NEW: CRLF, LF, CR handling
├── security/                         # NEW CATEGORY
│   ├── test-injection.sh             # Command/code injection
│   └── test-eval-safety.sh           # trimv eval validation
├── stress/                           # NEW CATEGORY
│   ├── test-large-files.sh           # Performance with big data
│   └── test-long-strings.sh          # Memory limits
└── compatibility/                    # NEW CATEGORY
    ├── test-bash-versions.sh         # Different Bash versions
    └── test-platforms.sh             # macOS, Linux, BSD
```

---

## Immediate Action Items

1. **Create test-error-handling.sh** - Validate all error paths
2. **Create test-unicode.sh** - Modern text support
3. **Create test-trimv-advanced.sh** - Variable validation
4. **Create test-security.sh** - Injection protection

These 4 files would add ~100 new assertions and significantly improve coverage.

#fin
