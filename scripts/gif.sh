#!/bin/bash

# Find all directories ending with '-result'
result_dirs=$(find . -type d -name "*-result")

# Initialize counters
total_gifs=0
moved_gifs=0

for result_dir in $result_dirs; do
    echo "Processing directory: $result_dir"

    # Find all .gif files within the current result directory
    gif_files=$(find "$result_dir" -maxdepth 1 -type f -name "*.gif")
    
    # Skip if no .gif files are found
    if [[ -z "$gif_files" ]]; then
        echo "No .gif files found in $result_dir. Skipping."
        continue
    fi

    # Create the 'plots' folder if it doesn't exist
    plots_dir="${result_dir}/A"
    if [[ ! -d "$plots_dir" ]]; then
        echo "Creating plots directory in $result_dir."
        mkdir -p "$plots_dir"
    fi

    # Move each .gif file to the plots folder
    for gif in $gif_files; do
        if mv "$gif" "$plots_dir/"; then
            echo "Moved $gif to $plots_dir"
            moved_gifs=$((moved_gifs + 1))
        else
            echo "Failed to move $gif"
        fi
        total_gifs=$((total_gifs + 1))
    done
done

# Print the summary of the operation
echo "Operation Summary:"
echo "Total .gif files found: $total_gifs"
echo "Successfully moved: $moved_gifs"
echo "Failed to move: $((total_gifs - moved_gifs))"

