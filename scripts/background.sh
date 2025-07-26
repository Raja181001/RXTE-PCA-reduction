#!/bin/bash

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

    cd $directory || { 
        echo "Error: Could not enter directory $directory. Skipping."; 
        echo "$directory: 0 (Failed)"
        ((failed_dirs++))
        continue
    }
    cd ..

    # Run the script 3 times with different event names
for i in {1..1}; do
    event_names=$(cat "$directory/FP_std2.lis")
    range_var=$(cat "$directory/FP_xtefilt.lis")  # Read the single line from FP_xtefilt.lis

    # Convert content of FP_std2.lis into an array
    readarray -t event_names_array <<< "$event_names"

    # Process each line in FP_std2.lis using the single range_var
    for ((j=0; j<${#event_names_array[@]}; j++)); do
        event_name="${event_names_array[j]}"
        suffix=$((j + 1))  # Generate a unique suffix
        output_path="${directory}/background_${suffix}"  # Add the suffix to the output path

        echo "Processing event: $event_name with range: $range_var and output: $output_path"

        # Create a script for the current line
        script_content="$event_name 
$output_path
pca_bkgd_cmbrightvle_eMv20051128.mdl
${range_var}
16
yes
yes
caldb
pca_saa_history_20120104"

        # Generate a unique script filename with a suffix
        script_file="${directory}/scriptpower_${i}_${suffix}.txt"
        echo "$script_content" > "$script_file"

        # Execute saextrct using the generated script
        if pcabackest < "$script_file"; then
            echo "pcabackest executed for directory: $directory, iteration: $i, line: $suffix"
        else
            echo "Error: pcabackest failed for directory: $directory, iteration: $i, line: $suffix"
            dir_successful=0 # Mark as failed for this directory
        fi
    done
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

