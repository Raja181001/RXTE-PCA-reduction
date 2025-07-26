#!/bin/bash

# Check if XSPEC is installed
if ! command -v xspec &> /dev/null; then
    echo "XSPEC is not installed or not in your PATH."
    exit 1
fi

# Check if a terminal emulator is available
if ! command -v x-terminal-emulator &> /dev/null && ! command -v gnome-terminal &> /dev/null; then
    echo "No supported terminal emulator found (e.g., x-terminal-emulator, gnome-terminal)."
    exit 1
fi

# Create or clear the log files
success_log="plot_success.txt"
failure_log="plot_failure.txt"
> "$success_log"
> "$failure_log"

# Locate directories ending with -results to process
directories=$(find . -type d -name '*-result')
echo "Found directories: $directories"

# Process each directory
for dir in $directories; do
    echo "Processing directory: $dir"

    # Locate necessary files in the current directory
    data_file="${dir}/event_spectrum.pha"
    
    # Validate file detection
    if [[ ! -f $data_file ]]; then
        echo "Data file not found in directory $dir. Skipping."
        echo "$dir" >> "$failure_log"
        continue
    fi

    echo "Found data file: $data_file"

    # Define XSPEC command script
    xspec_script="xspec <<EOF
da $data_file
cpd /xw
pl ld
setp e
ig **-3.
setp ylog
iplot
hard event_spectrum.gif/gif
exit
EOF"

    # Run XSPEC commands in a new terminal
    if command -v x-terminal-emulator &> /dev/null; then
        cd "$dir"
        x-terminal-emulator -e bash -c "$xspec_script"
        result=$?
        cd ..
    elif command -v gnome-terminal &> /dev/null; then
        cd "$dir"
        gnome-terminal -- bash -c "$xspec_script"
        result=$?
        cd ..
    else
        echo "No supported terminal emulator available for directory $dir."
        echo "$dir" >> "$failure_log"
        continue
    fi

    # Log success or failure based on the command result
    if [[ $result -eq 0 ]]; then
        echo "Successfully processed directory: $dir"
        echo "$dir" >> "$success_log"
    else
        echo "Failed to process directory: $dir"
        echo "$dir" >> "$failure_log"
    fi
done

# Summary
echo "Processing complete."
echo "Success log: $success_log"
echo "Failure log: $failure_log"

