#!/bin/bash

# Search for directories ending with -result
for dir in *-result; do
    if [ -d "$dir" ]; then
        # Look for src.pha inside each -result directory
	echo "processing : $dir"
        pha_file="${dir}/src.pha"
        
        if [ -f "$pha_file" ]; then
            echo "Found src.pha in $dir"
            
            # Ensure we have permission to access the file
            chmod +r "$pha_file"
            chmod +x "$(dirname "$pha_file")"
            
            # Provide the input file to the Python script using a here document
            rxte_backfile <<EOF
$pha_file
EOF
            echo "process completed for the $pha_file"
        else
            echo "src.pha not found in $dir"
        fi
    fi
done

