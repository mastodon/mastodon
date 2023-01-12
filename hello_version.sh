#!/bin/bash

# Read the version from the file
version=$(cat HELLO_VERSION.txt)

# Split the version string into an array
IFS='.' read -a version_array <<< "$version"

# Increment the last element of the array (the patch number)
((version_array[2]++))

# Reconstruct the version string
new_version="${version_array[0]}.${version_array[1]}.${version_array[2]}"

# Update the file with the new version
echo $new_version > HELLO_VERSION.txt

echo $new_version