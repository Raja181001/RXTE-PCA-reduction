#!/bin/bash

# Files to store the success and failure directories
success_file="success_spectrum.txt"
failure_file="failure_spectrum.txt"

# Clear previous content if the files exist
> "$success_file"
> "$failure_file"

# Get the list of directories ending with "result"
directories=$(find . -maxdepth 1 -type d -name "*result" -printf "%f\n")

# Initialize counters for summary
total_dirs=0
successful_dirs=0
failed_dirs=0

# Iterate over the directories
for directory in $directories; do
    ((total_dirs++)) # Increment the total directory count
    echo "Processing directory: $directory"
    dir_successful=1 # Assume success initially

    cd "$directory" || { 
        echo "Error: Could not enter directory $directory. Skipping."; 
        echo "$directory: 0 (Failed)"
        ((failed_dirs++))
        echo "$directory" >> "$failure_file"
        continue
    }
    cd ..


    # Run the script 3 times with different event names
    for i in {1..1}; do
        event_name="event_bkg.pha"

        # Create a script for each directory
        script_content="${directory}/event_background.pha
${directory}/${event_name}
${directory}/chan.txt
"
        script_file="${directory}/scriptpower_${i}.txt"
        echo "$script_content" > "$script_file"

        # Execute rbnpha using the generated script
        if rbnpha < "$script_file"; then
            echo "rbnpha executed for directory: $directory, iteration: $i"
        else
            echo "Error: rbnpha failed for directory: $directory, iteration: $i"
            dir_successful=0 # Mark as failed for this directory
        fi
    done

    # Display per-directory result
    if [ $dir_successful -eq 1 ]; then
        echo "$directory: 1 (Success)"
        ((successful_dirs++))
        echo "$directory" >> "$success_file"
    else
        echo "$directory: 0 (Failed)"
        ((failed_dirs++))
        echo "$directory" >> "$failure_file"
    fi
done

# Display summary of execution
echo "---------------------------------------------"
echo "Execution Summary:"
echo "Total directories processed: $total_dirs"
echo "Successful directories: $successful_dirs"
echo "Failed directories: $failed_dirs"
echo "---------------------------------------------"
echo "Successful directories logged in: $success_file"
echo "Failed directories logged in: $failure_file"
