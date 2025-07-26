#!/bin/bash

# Find directories ending with '-result'
directories=$(find . -type d -name '*-result')

# Process each directory
for base_dir in $directories; do
    echo "Processing directory: $base_dir"
    
    # Search for files named 'background_1', 'background_2', etc., in the current directory
    background_files=$(find "$base_dir" -maxdepth 1 -type f -name 'background_*' 2>/dev/null)
    
    if [[ -z "$background_files" ]]; then
        echo "No files matching 'background_*' found in directory: $base_dir"
        continue
    fi
    
    # Write the list of files to 'background.xdf'
    output_file="${base_dir}/background.xdf"
    echo "$background_files" > "$output_file"
    echo "Generated $output_file with the following content:"
    cat "$output_file"
done

