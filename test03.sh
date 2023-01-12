#!/bin/dash


# Script to mainly test tigger log and other edge cases

PATH="$PATH:$(pwd)"

# Create a temporary test directory and add empty files for expected and received output
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

expected_output="$(mktemp)"
received_output="$(mktemp)"


# Remove the test directory after use 
trap 'rm "$expected_output" "$received_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# Test when new directory is created with tigger-init
tigger-init > "$received_output" 2>&1

cat > "$expected_output" <<EOF
Initialized empty tigger repository in .tigger
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Test if tigger-log is working with basic case
echo a > 1.txt  > /dev/null 2>&1
tigger-add 1.txt  > /dev/null 2>&1
tigger-commit -m "a"  > /dev/null 2>&1
echo aa >> 1.txt  > /dev/null 2>&1
tigger-add 1.txt  > /dev/null 2>&1
tigger-commit -m "aa"  > /dev/null 2>&1
tigger-log > "$received_output" 2>&1

cat > "$expected_output" <<EOF
0 a
1 aa
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Test if tigger-commit with nothing to commit
echo b > 2.txt  > /dev/null 2>&1
tigger-add 2.txt  > /dev/null 2>&1
tigger-commit -m "b"  > /dev/null 2>&1
tigger-commit -m "b" > "$received_output" 2>&1

cat > "$expected_output" <<EOF
nothing to commit
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Test if tigger-log will update even when tigger commit failed
tigger-log > "$received_output" 2>&1

cat > "$expected_output" <<EOF
0 a
1 aa
2 b
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

echo "Passed test"