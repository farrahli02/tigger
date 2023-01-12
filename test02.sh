#!/bin/dash


# Script to test tigger-add and tigger-commit

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

# Testing if tigger-commit is called without arguments
tigger-commit > "$received_output" 2>&1

cat > "$expected_output" <<EOF
usage: tigger-commit [-a] -m commit-message
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if tigger add and tigger commit shows correctly for basic case
echo a > 1.txt  > /dev/null 2>&1
tigger-add 1.txt  > /dev/null 2>&1
tigger-commit -m 'first'  > /dev/null 2>&1
tigger-show 0:1.txt > "$received_output" 2>&1

cat > "$expected_output" <<EOF
a
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if tigger add and tigger commit shows correctly for when tigger show is without a commit number
echo aa >> 1.txt  > /dev/null 2>&1
tigger-add 1.txt  > /dev/null 2>&1
tigger-show :1.txt > "$received_output" 2>&1

cat > "$expected_output" <<EOF
aa
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if tigger commit prints right error message when there are no changes
tigger-commit -m 'second'
tigger-commit -m 'third' > "$received_output" 2>&1

cat > "$expected_output" <<EOF
nothing to commit
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

echo "Passed test"