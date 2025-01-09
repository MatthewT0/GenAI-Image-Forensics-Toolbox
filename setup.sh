#!/bin/bash
# Set the root directory to the current working directory
rootdir=$(pwd)

# Define the directory paths
dirpaths=("$rootdir/Dataset/Tampered" "$rootdir/Dataset/Authentic" "$rootdir/Dataset/Masks")

# Loop through each directory path
for dirpath in "${dirpaths[@]}"; do
    if [ ! -d "$dirpath" ]; then
        mkdir -p "$dirpath"
    fi
done