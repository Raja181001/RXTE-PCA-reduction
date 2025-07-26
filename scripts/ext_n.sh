#!/bin/bash

# Prompt the user for a directory name
read -p "Enter the directory name ending with '-result': " input_dir

# Remove trailing slash if present
input_dir="${input_dir%/}"

# Check if the directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Directory '$input_dir' does not exist. Exiting."
    exit 1
fi

echo "Processing directory: $input_dir"

# Check for FP_xtefilt.lis file
if [ ! -e "${input_dir}/FP_xtefilt.lis" ]; then
    echo "Error: ${input_dir}/FP_xtefilt.lis not found. Exiting."
    exit 1
fi

# Extract the filtfile
filtfile=$(cat "${input_dir}/FP_xtefilt.lis")

# Execute maketime to create good.gti
maketime infile="${filtfile}" \
    outfile=good.gti \
    expr="(ELV > 4) && (OFFSET < 0.1) && (NUM_PCU_ON > 0) && .NOT. ISNULL(ELV) && (NUM_PCU_ON < 6)" \
    value=VALUE time=TIME prefr=0.5 postfr=0.5 compact=NO clobber=YES

# Check if good.gti was created
if [ ! -e "good.gti" ]; then
    echo "Error: Failed to create good.gti for directory $input_dir. Exiting."
    exit 1
fi

echo "Good time interval (GTI) file created successfully for $input_dir."

# Execute pcaextspect2
if ! pcaextspect2 \
    src_infile=@${input_dir}/FP_dtstd2.lis \
    bkg_infile=@${input_dir}/FP_dtbkg2.lis \
    src_phafile=src.pha bkg_phafile=bkg.pha \
    gtiandfile=good.gti \
    filtfile=@${input_dir}/FP_xtefilt.lis \
    respfile=src.rsp \
    pculist=ALL layerlist=ALL; then
    echo "Error: pcaextspect2 failed for directory $input_dir. Exiting."
    exit 1
fi

# Execute pcaextlc2
if ! pcaextlc2 \
    src_infile=@${input_dir}/FP_dtstd2.lis \
    bkg_infile=@${input_dir}/FP_dtbkg2.lis \
    outfile=all.lc \
    gtiandfile=good.gti \
    pculist=ALL layerlist=ALL binsz=16; then
    echo "Error: pcaextlc2 failed for directory $input_dir. Exiting."
    exit 1
fi

echo "Commands executed successfully for directory: $input_dir"

# Move generated files to the directory
for file in good.gti all.lc src.pha bkg.pha src.rsp; do
    if [ -e "$file" ]; then
        mv "$file" "$input_dir"
        echo "$file moved to $input_dir."
    else
        echo "$file not found in the current directory."
    fi
done

# Final message
echo "All operations completed successfully for $input_dir."
