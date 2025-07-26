#!/bin/bash

# Get the list of directories ending with "result"
directories=$(find . -maxdepth 1 -type d -name "*result" -printf "%f\n")

# Define ranges for each iteration
range1="0-255"
range2="7-13"
range3="14-48"

# Initialize counters for summary
total_dirs=0
successful_dirs=0
failed_dirs=0

# Iterate over the directories
for directory in $directories; do
    ((total_dirs++)) # Increment the total directory count
    echo "Processing directory: $directory"
    dir_successful=1 # Assume success initially

    cd $directory || { 
        echo "Error: Could not enter directory $directory. Skipping."; 
        echo "$directory: 0 (Failed)"
        ((failed_dirs++))
        continue
    }
    cd ..

    # Run the script 3 times with different event names
    for i in {1..3}; do
        event_name="hard${i}"
        range_var="range${i}"

        # Create a script for each directory
        script_content="@${directory}/FP_dtstd2.lis
-
${directory}/good.gti
${directory}/${event_name}
ONE
TIME
GOOD
16
LIGHTCURVE
RATE
SUM
INDEF
INDEF
INDEF
INDEF
INDEF
${!range_var}
INDEF"

        script_file="${directory}/scriptpower_${i}.txt"
        echo "$script_content" > "$script_file"

        # Execute saextrct using the generated script
        if saextrct < "$script_file"; then
            echo "saextrct executed for directory: $directory, iteration: $i"
        else
            echo "Error: saextrct failed for directory: $directory, iteration: $i"
            dir_successful=0 # Mark as failed for this directory
        fi
    done

    # Display per-directory result
    if [ $dir_successful -eq 1 ]; then
        echo "$directory: 1 (Success)"
        ((successful_dirs++))
    else
        echo "$directory: 0 (Failed)"
        ((failed_dirs++))
    fi
done

# Display summary of execution
echo "---------------------------------------------"
echo "Execution Summary:"
echo "Total directories processed: $total_dirs"
echo "Successful directories: $successful_dirs"
echo "Failed directories: $failed_dirs"
echo "---------------------------------------------"

