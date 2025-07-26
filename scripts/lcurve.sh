#!/bin/bash

# Get the list of directories ending with "-result"
directories=$(find . -maxdepth 1 -type d -name "*-result" -printf "%f\n")
curr=$(pwd)

# Loop through each directory
for directory in $directories; do
    # Find all.lc files in the directory
    lc_files=$(find "$curr/$directory" -maxdepth 1 -type f -name "event.lc")

    # Iterate over each all.lc file
    for lc_file in $lc_files; do
        # Extract basename for the lc file
        lc_basename=$(basename "$lc_file")
       
        # Create a script for the all.lc file
        script_content="1
$lc_basename
-
0.125
300000
0
out
yes
/xw
line on
pl
hard ${lc_basename%.lc}.gif/gif
q"

        script_file="${curr}/${directory}/lcurve_${lc_basename%.lc}.txt"
        echo "$script_content" > "$script_file"
       
        # Change directory and run the script in a new terminal window
        gnome-terminal --working-directory="${curr}/${directory}" -- bash -c "lcurve < ${script_file} | tee ${lc_basename%.lc}_lcurve.txt"
    done

done

echo "[INFO] Processing complete. Check the generated .gif files in respective directories."

