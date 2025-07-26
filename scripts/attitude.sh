#!/bin/bash

# Define the directory pattern (numeric only, e.g., 12345-67-89-01)
indir_pattern="^[0-9]{5}-[0-9]+-[0-9]+-[0-9]+$"

# Locate all directories and filter based on the pattern
source_dirs=$(find . -maxdepth 1 -type d -printf "%f\n" | grep -E "$indir_pattern")
echo $source_dirs
# Initialize counters
total_files_extracted=0
total_skipped_dirs=0

# Process each matching directory
for dir in $source_dirs; do
    echo "Processing directory: $dir"

    # Define the target results directory
    results_dir="${dir}-result"

    # Check if the results directory exists
    if [[ ! -d "$results_dir" ]]; then
        echo "Results directory $results_dir does not exist. Skipping."
        ((total_skipped_dirs++))
        continue
    fi

    # Find files starting with FH0e and ending with .gz in the current directory
    files_to_extract=$(find "$dir" -type f -name 'FH0e*.gz')

    if [[ -z $files_to_extract ]]; then
        echo "No files matching 'FH0e*.gz' found in $dir."
        continue
    fi

    # Extract each matching file and rename to "attitude"
    for file in $files_to_extract; do
        target_file="${results_dir}/attitude"
        if [[ -f "$target_file" ]]; then
            echo "File named 'attitude' already exists in $results_dir. Skipping extraction for $file."
            continue
        fi

        echo "Extracting and renaming file: $file to $target_file"
        gunzip -c "$file" > "$target_file"
        if [[ $? -eq 0 ]]; then
            echo "Successfully extracted and renamed: $file"
            ((total_files_extracted++))
        else
            echo "Error extracting $file. Skipping."
        fi
    done
done

# Summary
echo "---------------------------------------------"
echo "Script Execution Summary:"
echo "Total files extracted and renamed: $total_files_extracted"
echo "Total directories skipped (results directory missing): $total_skipped_dirs"
echo "---------------------------------------------"

