#!/bin/bash

# Ensure the script is executed in the desired base location
echo "Running the script in the current directory: $(pwd)"

# Define the directory pattern (numeric only, e.g., 12345-67-89-01)
indir_pattern="^[0-9]{5}-[0-9]+-[0-9]+-[0-9]+$"

# Locate all directories and filter based on the pattern
source_dirs=$(find . -maxdepth 1 -type d -printf "%f\n" | grep -E "$indir_pattern")

# Initialize counters
total_dirs=0
successful_copies=0
failed_copies=0

# Process each valid source directory
for source_dir in $source_dirs; do
    # Increment the total directories counter
    total_dirs=$((total_dirs + 1))

    # Define the full source directory path
    full_source_dir="./${source_dir}"

    # Define the destination directory
    result_dir="${full_source_dir}-result"

    # Check if the source file exists
    fits_file="${full_source_dir}/fits_files.god"
    if [[ ! -f "$fits_file" ]]; then
        echo "File '.god' not found in $source_dir. Skipping."
        failed_copies=$((failed_copies + 1))
        continue
    fi

    # Check if the destination directory exists; create it if not
    if [[ ! -d "$result_dir" ]]; then
        echo "Result directory $result_dir not found. Creating it."
        mkdir -p "$result_dir"
    fi

    # Copy the file
    if cp "$fits_file" "$result_dir/"; then
        echo "Copied '.god' from $source_dir to $result_dir"
        successful_copies=$((successful_copies + 1))
    else
        echo "Failed to copy '.god' from $source_dir to $result_dir"
        failed_copies=$((failed_copies + 1))
    fi
done

# Print the summary of the operation
echo "Operation Summary:"
echo "Total directories processed: $total_dirs"
echo "Successful copies: $successful_copies"
echo "Failed copies: $failed_copies"
