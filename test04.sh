#!/bin/dash

# Script to mainly test tigger show and other edge cases

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

# Testing if tigger add and tigger commit shows correctly for basic case
echo a > 1.txt 
tigger-add 1.txt
tigger-commit -m 'first'
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
echo aa >> 1.txt
tigger-add 1.txt
tigger-show :1.txt > "$received_output" 2>&1

cat > "$expected_output" <<EOF
aa
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if tigger-show is called with an invalid commit number
tigger-show 100:1.txt > "$received_output" 2>&1

cat > "$expected_output" <<EOF
tigger-show: error: unknown commit '100'
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi

# Testing if file given in tigger-show exists
tigger-show :non-existent_file > "$received_output" 2>&1

cat > "$expected_output" <<EOF
tigger-show: error: 'non-existent_file' not found in index
EOF

if ! diff "$expected_output" "$received_output"
then
    echo "Failed test"
    exit 1
fi



echo "Passed test"