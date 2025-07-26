#!/bin/bash

# Enable nullglob to handle cases where no directories match
shopt -s nullglob
dirs=(*-result/)
shopt -u nullglob

if [ ${#dirs[@]} -eq 0 ]; then
    echo "No directories ending with '-result' found. Exiting."
    exit 1
fi

# Loop through all directories ending with "-result"
for dir in "${dirs[@]}"; do
    # Remove the trailing slash
    dir="${dir%/}"

    echo "Processing directory: $dir"

    # Check if the directory exists
    if [ -d "$dir" ]; then
        # Check for FP_xtefilt.lis file
        if [ ! -e "${dir}/FP_xtefilt.lis" ]; then
            echo "Error: ${dir}/FP_xtefilt.lis not found. Skipping directory $dir."
            continue
        fi

        # Extract the filtfile
        filtfile=$(cat "${dir}/FP_xtefilt.lis")

        # Execute maketime to create good.gti
        maketime infile="${filtfile}" \
            outfile=good.gti \
            expr="(ELV > 4) && (OFFSET < 0.1) && (NUM_PCU_ON > 0) && .NOT. ISNULL(ELV) && (NUM_PCU_ON < 6)" \
            value=VALUE time=TIME prefr=0.5 postfr=0.5 compact=NO clobber=YES

        # Check if good.gti was created
        if [ ! -e "good.gti" ]; then
            echo "Error: Failed to create good.gti for directory $dir. Terminating script."
            exit 1
        fi

        echo "Good time interval (GTI) file created successfully for $dir."

        # Execute pcaextspect2
        if ! pcaextspect2 \
            src_infile=@${dir}/FP_dtstd2.lis \
            bkg_infile=@${dir}/FP_dtbkg2.lis \
            src_phafile=src.pha bkg_phafile=bkg.pha \
            gtiandfile=good.gti \
            filtfile=@${dir}/FP_xtefilt.lis \
            respfile=src.rsp \
            pculist=ALL layerlist=ALL; then
            echo "Error: pcaextspect2 failed for directory $dir. Terminating script."
            exit 1
        fi

        # Execute pcaextlc2
        if ! pcaextlc2 \
            src_infile=@${dir}/FP_dtstd2.lis \
            bkg_infile=@${dir}/FP_dtbkg2.lis \
            outfile=all.lc \
            gtiandfile=good.gti \
            pculist=ALL layerlist=ALL binsz=16; then
            echo "Error: pcaextlc2 failed for directory $dir. Terminating script."
            exit 1
        fi

        echo "Commands executed with directory: $dir"

        # Move generated files to the directory
        for file in good.gti all.lc src.pha bkg.pha src.rsp; do
            if [ -e "$file" ]; then
                mv "$file" "$dir"
                echo "$file moved to $dir."
            else
                echo "$file not found in the current directory."
            fi
        done
    else
        echo "Directory $dir does not exist or is not valid."
    fi
done

# Final message
echo "All operations completed successfully."
