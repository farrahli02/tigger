#!/bin/dash

# Script to mainly test tigger rm

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

# Testing tigger-rm for no arguements
tigger-rm > "$received_output" 2>&1

cat > "$expected_output" <<EOF
usage: tigger-rm [--force] [--cached] <filenames>
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi


echo "Test passed"