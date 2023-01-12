#!/bin/dash

# Script to test tigger-add

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

# Testing if no arguments are given for tigger-add
tigger-add > "$received_output" 2>&1

cat > "$expected_output" <<EOF
usage: tigger-add <filenames>
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if tigger-add is trying to add a file that is not in the directory or previous commit
tigger-add non-existent_file > "$received_output" 2>&1

cat > "$expected_output" <<EOF
tigger-add: error: can not open 'non-existent_file'
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi


echo "Passed test"