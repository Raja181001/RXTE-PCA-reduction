#!/bin/bash

# Enable nullglob to handle cases where no directories match
shopt -s nullglob

# Check for directories matching "*-*-*-*" with any 4-digit numeric prefix
indir_pattern="[0-9][0-9][0-9][0-9][0-9]-[0-9]*-[0-9]*-[0-9]*"
valid_dirs=()
for dir in $indir_pattern/; do
    # Remove trailing slash
    dir="${dir%/}"
    # Ensure directory ends with digits only (no alphabetic suffix)
    if [[ "$dir" =~ ^[0-9]{5}-[0-9]+-[0-9]+-[0-9]+$ ]]; then
        valid_dirs+=("$dir")
    fi
done

# Exit if no valid directories found
if [ ${#valid_dirs[@]} -eq 0 ]; then
    echo "No valid input directories found. Exiting."
    exit 1
fi

# Loop through all valid input directories
for indir in "${valid_dirs[@]}"; do
    echo "Processing input directory: $indir"

    # Define the output directory
    outdir="${indir}-result"

    # Execute pcaprepobsid
    if ! pcaprepobsid indir="$indir" outdir="$outdir"; then
        echo "Error: pcaprepobsid failed for directory $indir. Skipping."
        continue
    fi

    echo "pcaprepobsid completed successfully for $indir. Output directory: $outdir"

    # Check for directories ending with "-result"
    result_dirs=(*-result/)
    if [ ${#result_dirs[@]} -eq 0 ]; then
        echo "No '-result' directories found. Exiting."
        exit 1
    fi

    # Process each "-result" directory
    for dir in "${result_dirs[@]}"; do
        dir="${dir%/}"
        echo "Processing directory: $dir"

        # Check for FP_xtefilt.lis
        if [ ! -e "${dir}/FP_xtefilt.lis" ]; then
            echo "Error: ${dir}/FP_xtefilt.lis not found. Skipping directory $dir."
            continue
        fi

        # Extract the filtfile
        filtfile=$(cat "${dir}/FP_xtefilt.lis")

        # Execute maketime
        maketime infile="${filtfile}" \
            outfile=good.gti \
            expr="(ELV > 4) && (OFFSET < 0.1) && (NUM_PCU_ON > 0) && .NOT. ISNULL(ELV) && (NUM_PCU_ON < 6)" \
            value=VALUE time=TIME prefr=0.5 postfr=0.5 compact=NO clobber=YES

        # Check if good.gti was created
        if [ ! -e "good.gti" ]; then
            echo "Error: Failed to create good.gti for directory $dir. Skipping."
            continue
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
            echo "Error: pcaextspect2 failed for directory $dir. Skipping."
            continue
        fi

        # Execute pcaextlc2
        if ! pcaextlc2 \
            src_infile=@${dir}/FP_dtstd2.lis \
            bkg_infile=@${dir}/FP_dtbkg2.lis \
            outfile=all.lc \
            gtiandfile=good.gti \
            pculist=ALL layerlist=ALL binsz=16; then
            echo "Error: pcaextlc2 failed for directory $dir. Skipping."
            continue
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
    done
done

# Final message
echo "All operations completed successfully."
