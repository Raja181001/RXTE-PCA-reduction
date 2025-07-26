import os
import gzip
import astropy.io.fits as fits
import csv
import re

def read_fits_header(file_path):
    try:
        print(f"Reading FITS file: {file_path}")
        with fits.open(file_path) as hdul:
            if 'XTE_SE' in hdul:  # Check for 'XTE_SE' extension
                header = hdul['XTE_SE'].header
                datamode = header.get('DATAMODE', 'N/A')
                ddesc = header.get('DDESC', 'N/A')
                return datamode, ddesc
            else:
                print(f"'XTE_SE' extension not found in {file_path}")
                return 'N/A', 'N/A'
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        return 'Error', 'Error'

def process_fits_file(file_path):
    try:
        print(f"Processing FITS file: {file_path}")
        if file_path.endswith('.gz'):
            with gzip.open(file_path, 'rb') as f:
                with fits.open(f) as hdul:
                    if 'XTE_SE' in hdul:
                        header = hdul['XTE_SE'].header
                        datamode = header.get('DATAMODE', 'N/A')
                        ddesc = header.get('DDESC', 'N/A')
                        return datamode, ddesc
                    else:
                        print(f"'XTE_SE' extension not found in {file_path}")
                        return 'N/A', 'N/A'
        else:
            return read_fits_header(file_path)
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
        return 'Error', 'Error'

def process_fits_in_directory(directory):
    data = []
    file_paths = []
    print(f"Scanning directory for FITS files: {directory}")
    fits_files_found = False
    for root, _, files in os.walk(directory):
        if not files:
            print(f"No files found in {root}")
        for file in files:
            # Consider all files without an extension or with .gz as FITS files
            if ('.' not in file or file.endswith('.gz')) and file.startswith('F'):
                fits_files_found = True
                file_path = os.path.abspath(os.path.join(root, file))
                datamode, ddesc = process_fits_file(file_path)
                if datamode != 'N/A':
                    data.append([file, datamode, ddesc])
                    file_paths.append(file_path)
    if not fits_files_found:
        print(f"No FITS files found in directory: {directory}")
    return data, file_paths

def process_main_directory(main_directory):
    # Regex to match directories that end with numbers
    number_directory_pattern = re.compile(r'.*\d+$')
    errors = []
    
    # List all directories in the main directory
    print(f"Scanning main directory: {main_directory}")
    for root, dirs, _ in os.walk(main_directory, topdown=True):
        # Only consider immediate subdirectories of the main directory
        if root == main_directory:
            if not dirs:
                print(f"No subdirectories found in {root}")
            for dir_name in dirs:
                # Check if the directory name ends with a number
                if number_directory_pattern.match(dir_name):
                    pca_folder = os.path.join(root, dir_name, 'pca')
                    if os.path.isdir(pca_folder):
                        # Process all FITS files in the pca folder
                        print(f"Processing directory: {pca_folder}")
                        data, file_paths = process_fits_in_directory(pca_folder)
                        
                        # Define CSV file path inside the numbered directory but outside the pca folder
                        csv_file_path = os.path.join(root, dir_name, 'fits_data_summary.csv')
                        xdf_file_path = os.path.join(root, dir_name, 'fits_files.god')
                        
                        # Write the data to a CSV file in the numbered directory
                        try:
                            if data:
                                with open(csv_file_path, mode='w', newline='') as csv_file:
                                    csv_writer = csv.writer(csv_file)
                                    csv_writer.writerow(['Filename', 'DATAMODE', 'DDESC'])
                                    csv_writer.writerows(data)
                                print(f"Data written to {csv_file_path}")
                                
                                # Write the file paths to the text file in the numbered directory
                                with open(xdf_file_path, mode='w') as xdf_file:
                                    written_files = set()
                                    for file_path in file_paths:
                                        base_name = os.path.basename(file_path)
                                        if base_name not in written_files or file_path.endswith('.gz'):
                                            written_files.add(base_name)
                                            xdf_file.write(f"{file_path.rstrip('.gz')}\n")
                                print(f"File paths written to {xdf_file_path}")
                            else:
                                print(f"No data to write for directory: {pca_folder}")
                        except Exception as e:
                            error_message = f"Error writing CSV or text file in {dir_name}: {e}"
                            print(error_message)
                            errors.append(error_message)
                    else:
                        print(f"PCA folder not found: {pca_folder}")
    
    # Print summary of errors
    if errors:
        print("\nSummary of errors:")
        for error in errors:
            print(error)

if __name__ == "__main__":
    main_directory = input("Enter the main directory path: ")
    process_main_directory(main_directory)
    print("Processing complete.")
