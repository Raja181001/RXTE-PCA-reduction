#!/bin/bash

# Locate directories ending with -result
directories=$(find . -type d -name '*-result')

# Initialize counters
total_files_deleted=0

# Process each directory
for dir in $directories; do
    echo "Processing directory: $dir"

    # Find files starting with FH0e and ending with .gz
    files_to_delete=$(find "$dir" -type f -name 'FH0e*.gz')

    if [[ -z $files_to_delete ]]; then
        echo "No files matching the pattern 'FH0e*.gz' found in $dir."
        continue
    fi

    # Delete the matching files
    for file in $files_to_delete; do
        echo "Deleting file: $file"
        rm "$file"
        ((total_files_deleted++))
    done
done

# Summary
echo "---------------------------------------------"
echo "Script Execution Summary:"
echo "Total files deleted: $total_files_deleted"
echo "---------------------------------------------"

