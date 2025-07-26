#!/bin/bash

# Ensure the script is executed in the desired base location
echo "Running pcaprepobsid in the current directory: $(pwd)"

# Define the directory pattern (numeric only, e.g., 12345-67-89-01)
indir_pattern="^[0-9]{5}-[0-9]+-[0-9]+-[0-9]+$"

# Initialize an array to store valid directories
valid_dirs=()

# Loop through all directories in the current location
for indir in */; do
    # Remove the trailing slash from the directory name
    indir="${indir%/}"

    # Check if the directory name matches the numeric pattern
    if [[ "$indir" =~ $indir_pattern ]]; then
        # Add to the list of valid directories
        valid_dirs+=("$indir")
    else
        echo "Skipping invalid directory: $indir"
    fi
done

# Process each valid directory
for indir in "${valid_dirs[@]}"; do
    # Print the directory being processed
    echo "Processing folder: $indir"

    # Define the outdir as <directory-name>-result
    outdir="${indir}-result"

    # Execute the pcaprepobsid command
    echo "Running pcaprepobsid for indir='$indir' and outdir='$outdir'..."
    pcaprepobsid indir="$indir" outdir="$outdir"
done

# Print a completion message
echo "Processing complete. Total valid directories processed: ${#valid_dirs[@]}"

