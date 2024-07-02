# Define paths
$gitRepoPath = (pwd).Path
$env_source = "$gitRepoPath\compile_targets\python\env"   
$build_destination = "$gitRepoPath\compile_targets\python\test\local\build"   
$package_create = "$build_destination\env"   
$package_install = "$build_destination\env\dist"   
$envFilePath = "$gitRepoPath\compile_targets\python\env\environment.yml"  

# Extract the environment name from the environment.yml file
$envName = (Select-String -Path $envFilePath -Pattern '^name:' | ForEach-Object { $_ -replace '^name:\s*', '' }).Trim()

# Function to check if a Conda environment exists
function Check-CondaEnvExists {
    conda env list | Select-String -Pattern "^\s*$envName\s" | ForEach-Object { $_ } | Out-Null
}

# Check if the Conda environment exists
if (-not (Check-CondaEnvExists)) {
    conda env create -f $envFilePath
}

conda activate $envName

Write-Output "Conda environment '$envName' is activated"

# Read the package name from setup.py
$package_name = (Select-String -Path "$env_source\setup.py" -Pattern "packages=" | ForEach-Object { $_ -split "'" })[1]

# Create the necessary folder in the env directory with the package name
New-Item -ItemType Directory -Force -Path "$env_source\$package_name" | Out-Null

# Create __init__.py file in the package directory
New-Item -ItemType File -Force -Path "$env_source\$package_name\__init__.py" | Out-Null

if (Test-Path $build_destination) {
    # Check if env folder exists in build directory
    if (Test-Path "$build_destination\env") {
        # Remove existing env folder in build directory
        Write-Output "Removing existing env folder in build directory..."
        Remove-Item -Recurse -Force "$build_destination\env"
    }
    
    # Copy env folder to build folder
    Copy-Item -Recurse -Force $env_source $build_destination
    Write-Output "env folder copied to build folder successfully"
    
    # Move all .pb2.py files to the package directory
    Get-ChildItem -Path "$build_destination\*_pb2.py" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination "$package_create\$package_name"
        Write-Output "Copied $($_.Name) to $package_name folder."
    }

    # Navigate to the build destination
    Set-Location -Path $package_create

    # Run the Python setup commands
    python setup.py sdist bdist_wheel
    Write-Output "Python package build completed successfully."

    # Install the package
    pip install "$package_install\*.whl"

    Set-Location -Path $gitRepoPath
} else {
    Write-Output "Folder does not exist: $build_destination"
}
