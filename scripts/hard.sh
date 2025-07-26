#!/bin/bash

# Get the list of directories ending with "results"
directories=$(find . -maxdepth 1 -type d -name "*result" -printf "%f\n")
curr=$(pwd)

# Loop through all the identified directories
for directory in $directories; do
    echo "[INFO] Processing directory: $directory"

    # Define color file names
    color1_file="singlelc2.lc"
    color2_file="singlelc3.lc"

    # Construct full paths for the color files
    color1_path="${curr}/${directory}/${color1_file}"
    color2_path="${curr}/${directory}/${color2_file}"

    # Check if all the required files exist
    if [[ -f "$color1_path" && -f "$color2_path" ]]; then
        echo "[INFO] All required color files exist in $directory"

        # Create the content for the lcurve script
        script_content="2
${color1_file}
${color2_file}
-
5
552824
out
yes
/xw
3
ma 5 on 1..9
error off
hardcopy hard_evt5.gif/gif
q"

        # Save the script content to a file
        script_file="${curr}/${directory}/lcurve_script.txt"
        echo "$script_content" > "$script_file"

        # Run the lcurve command in a new terminal
        gnome-terminal --working-directory="${curr}/${directory}" -- bash -c "lcurve < ${script_file} | tee lcurve_output.txt"
        echo "[INFO] Created GIF and lcurve output in $directory"
    else
        # Log a warning if any of the required files are missing
        echo "[WARNING] Missing one or more required color files in $directory"
    fi
done

