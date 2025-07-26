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

# Locate directories ending with -results to process
directories=$(find . -type d -name '*-result')
echo $directories
# Process each directory
for dir in $directories; do
    echo "Processing directory: $dir"

    # Locate necessary files in the current directory
    data_file='event_spectrum.pha'
    attitude_file='attitude'
    echo $data_file
    echo $attitude_file
    # Validate file detection
    if [[ -z $attitude_file ]]; then
        echo "Data file (e.g., 'FH0e*') not found in directory $dir. Skipping."
        continue
    fi
    
    echo "Found data file:"

    # Define XSPEC command script
    xspec_script="pcarsp <<EOF
$data_file
$attitude_file
all
y
all
y
EOF"

    # Run XSPEC commands in a new terminal
    if command -v x-terminal-emulator &> /dev/null; then
    	cd ${dir}
        x-terminal-emulator -e bash -c "$xspec_script"
        cd ..
    elif command -v gnome-terminal &> /dev/null; then
    	cd ${dir}
        gnome-terminal -- bash -c "$xspec_script"
        cd ..
    else
        echo "No supported terminal emulator available for directory $dir."
        continue
    fi

    echo "Commands executed in a new terminal for directory $dir."
done

echo "Processing complete."

