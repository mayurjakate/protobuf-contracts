#!/bin/bash

# Define paths
gitRepoPath=$(pwd)
env_source="$gitRepoPath/compile_targets/python/env"  # Path to the source env folder
build_destination="$gitRepoPath/compile_targets/python/test/local/build"  # Path to the destination build folder
package_create="$build_destination/env"  # Path to the package creation inside build
package_install="$build_destination/env/dist"  # Path to the package install inside build
envFilePath="$gitRepoPath/compile_targets/python/env/environment.yml"  # Path to the environment.yml file

# Extract the environment name from the environment.yml file
envName=$(grep '^name:' "$envFilePath" | cut -d ' ' -f 2)

# Function to check if a Conda environment exists
function check_conda_env_exists() {
    conda env list | grep -w "$envName" &> /dev/null
}

# Check if the Conda environment exists
if ! check_conda_env_exists; then
    conda env create -f "$envFilePath"
fi

conda activate "$envName"

echo "Conda environment '$envName' is activated"

# Read the package name from setup.py
package_name=$(grep "packages=" "$env_source/setup.py" | cut -d "'" -f 2)

# Create the necessary folder in the env directory with the package name
mkdir -p "$env_source/$package_name"

# Create __init__.py file in the package directory
touch "$env_source/$package_name/__init__.py"

if [ -d "$build_destination" ]; then
    # Check if env folder exists in build directory
    if [ -d "$build_destination/env" ]; then
        # Remove existing env folder in build directory
        echo "Removing existing env folder in build directory..."
        rm -rf "$build_destination/env"
    fi
    
    # Copy env folder to build folder
    cp -r "$env_source" "$build_destination"
    echo "env folder copied to build folder successfully"
    
    # Move all .pb2.py files to the package directory
    for pb2_file in "$build_destination"/*_pb2.py; do
        if [ -e "$pb2_file" ]; then
            cp "$pb2_file" "$package_create/$package_name"
            echo "Copied $pb2_file to $package_name folder."
        fi
    done

    # Navigate to the build destination
    cd "$package_create" || exit

    # Run the Python setup commands
    python setup.py sdist bdist_wheel
    echo "Python package build completed successfully."

    # Install the package
    pip install "$package_install"/*.whl

    cd "$gitRepoPath" || exit
else
    echo "Folder does not exist: $build_destination"
fi
