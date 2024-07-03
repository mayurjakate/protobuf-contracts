#!/bin/bash

# Define paths
gitRepoPath=$(pwd)
envFolderPath="$gitRepoPath/compile_targets/python/env"
buildFolderPath="$gitRepoPath/compile_targets/python/test/build"
buildEnvFolderPath="$buildFolderPath/env"
envCondaFilePath="$buildEnvFolderPath/environment.yml"
wheelFolder="$buildEnvFolderPath/dist"

# Setup Environment

# Check if env folder exists in build directory
if [ -d "$buildFolderPath" ]; then

    # Remove existing env folder in build directory
    if [ -d "$buildEnvFolderPath" ]; then
        echo "Removing existing env folder in build directory..."
        rm -rf "$buildEnvFolderPath"
    fi

    # Copy env folder to test/build folder
    cp -r "$envFolderPath" "$buildFolderPath"

    # Read the package name from setup.py file
    packageFolderName=$(grep "packages=" "$buildEnvFolderPath/setup.py" | cut -d "'" -f 2)

    # Create the necessary folder in the env directory with the package name
    mkdir -p "$buildEnvFolderPath/$packageFolderName"

    # Create __init__.py file in the package directory
    touch "$buildEnvFolderPath/$packageFolderName/__init__.py"

    # Copy .pb2.py Files to the Python Environment
    cp "$buildFolderPath/contracts/"*_pb2.py "$buildEnvFolderPath/$packageFolderName"

    # Conda Environment

    # Extract the conda environment name from the environment.yml file
    envCondaName="eventscontract-env" #$(grep '^name:' "$envCondaFilePath" | cut -d ' ' -f 2)

    # Function to check if a Conda environment exists
    check_conda_env_exists() {
        conda env list | grep -w "$envCondaName" > /dev/null
    }

    # Check if the Conda environment exists
    if ! check_conda_env_exists; then
        conda env create -f "$envCondaFilePath"
    fi

    conda activate "$envCondaName"

    echo "Conda environment '$envCondaName' is activated"
    
    # Navigate to the build destination
    cd "$buildEnvFolderPath"
    
    # Run the Python setup commands
    python setup.py sdist bdist_wheel
    echo "Python package build completed successfully."
    
    # Install the package
    pip install "$wheelFolder/$packageFolderName-0.0.0-py3-none-any.whl"
    
    # Back to Root Folder
    cd "$gitRepoPath"
else
    echo "Folder does not exist: $buildFolderPath"
fi
