# Bash String Trim Utilities

Lightweight Bash functions for removing whitespace from strings and streams.

## Functions

- **trim** - Remove leading and trailing whitespace
- **ltrim** - Remove only leading whitespace
- **rtrim** - Remove only trailing whitespace
- **trimv** - Assign trimmed result to a variable
- **trimall** - Normalize all whitespace (collapse multiple spaces)

## Usage

```bash
# Basic string trimming
trim "  hello world  "       # "hello world"
ltrim "  hello world  "      # "hello world  "
rtrim "  hello world  "      # "  hello world"

# Process files
trim < input.txt > clean.txt

# Store in variable
trimv -n result "  hello world  "
echo "$result"               # "hello world"

# Normalize whitespace
trimall "  multiple    spaces   here  "  # "multiple spaces here"
```

## Options

- **trim [-e] string**
  - `-e` Process escape sequences in the input string

- **trimv -n varname string**
  - `-n varname` Name of variable to store result (defaults to `TRIM`)

## Implementation Details

- Uses efficient Bash parameter expansion with `[:blank:]` character class
- No external dependencies (sed/awk)
- Handles both command-line arguments and stdin (except trimall)
- Uses pure Bash features for maximum portability
- Functions both as modules (to be sourced) and standalone executables

## Examples

```bash
# Clean user input
cleaned=$(trim "$user_input")

# Remove indentation but keep trailing spaces
config_line="    key = value   "
key_value=$(ltrim "$config_line")  # "key = value   "

# Remove trailing newlines from file content
rtrim < file.txt > clean_file.txt

# Normalize for comparison (ignoring whitespace differences)
if [[ "$(trimall "$string1")" == "$(trimall "$string2")" ]]; then
  echo "Strings match when normalized"
fi

# Process escape sequences
escaped_input="Hello\\tWorld\\n"
trim -e "$escaped_input"  # Output: "Hello	World"

# Capture file content in variable
trimv -n content < data.txt
echo "Content: $content"

# Create normalized CSV data
csv_line="  field1 ,   field2,field3   "
normalized=$(echo "$csv_line" | trim | tr ',' '\n' | trim)
echo "$normalized"  # Clean fields, one per line

# Use in loops
for file in *.txt; do
  # Get file basename without extension and trim whitespace
  name=$(basename "$file" .txt | trim)
  echo "Processing: $name"
done

# Combine with other commands
find . -name "*.conf" -exec cat {} \; | grep "^[[:space:]]*setting" | ltrim | sort
```

## Installation

Install directly from GitHub with this one-liner:

```bash
sudo bash -c "git clone https://github.com/Open-Technology-Foundation/trim /usr/share/trim && chmod +x /usr/share/trim/*.bash && ln -sf /usr/share/trim/trim.bash /usr/local/bin/trim && ln -sf /usr/share/trim/ltrim.bash /usr/local/bin/ltrim && ln -sf /usr/share/trim/rtrim.bash /usr/local/bin/rtrim && ln -sf /usr/share/trim/trimv.bash /usr/local/bin/trimv && ln -sf /usr/share/trim/trimall.bash /usr/local/bin/trimall"
```

This will:
1. Clone the repository to `/usr/share/trim`
2. Make all scripts executable
3. Create symlinks in `/usr/local/bin` for each utility

## License

GNU General Public License v3.0 - See the LICENSE file for details.

GitHub Repository: https://github.com/Open-Technology-Foundation/trim

#fin