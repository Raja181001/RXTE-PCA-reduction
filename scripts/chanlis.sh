#!/bin/bash

# Check if XSPEC is installed
if ! command -v xspec &> /dev/null; then
    echo "HEASOFT is not intialised"
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
    chan_file='chan.txt'
    echo $data_file
    # Validate file detection
    if [[ -z $data_file ]]; then
        echo "Data file (e.g., '*src.pha') not found in directory $dir. Skipping."
        continue
    fi

    echo "Found data file: $data_file"

    # Define XSPEC command script
    xspec_script="rddescr <<EOF
$data_file
$chan_file
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

