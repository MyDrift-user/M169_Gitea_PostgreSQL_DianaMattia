# Create folder and navigate into it
New-Item -ItemType Directory -Path "M169DianaMattia" -Force
Set-Location -Path "M169DianaMattia"

# Download and extract repository
Invoke-WebRequest -Uri "https://github.com/MyDrift-user/M169_Gitea_PostgreSQL_DianaMattia/archive/refs/heads/main.tar.gz" -OutFile "m169.tar.gz"
tar -xzf m169.tar.gz
Remove-Item m169.tar.gz
Set-Location M169_Gitea_PostgreSQL_DianaMattia-main

# Check if Docker is installed and running
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerInstalled) {
    Write-Error "Docker is not installed. Please install Docker Desktop before running this script."
    exit 1
}

$useTemplate = Read-Host "Do you want to use the .env.template file? (y/n, default is 'y')"

if ($useTemplate -eq 'n') {
    # Read the template file
    $envContent = Get-Content ".env.template"

    # Create a new .env file
    $envFilePath = ".env"
    New-Item -ItemType File -Path $envFilePath -Force

    # Loop through each line in the template and prompt for user input
    foreach ($line in $envContent) {
        if ($line -match "^(.*)=(.*)$") {
            $key = $matches[1]
            $defaultValue = $matches[2]
            $userValue = Read-Host "Enter value for $key (default is '$defaultValue')"

            # Use default value if user input is empty
            if (-not [string]::IsNullOrWhiteSpace($userValue)) {
                $line = "$key=$userValue"
            } else {
                $line = "$key=$defaultValue"
            }
        }
        # Append the line to the .env file
        Add-Content -Path $envFilePath -Value $line
    }
} else {
    # Rename the .env.template to .env
    Rename-Item -Path ".env.template" -NewName ".env" -Force
}


if ($dockerInstalled) {
    # Load Docker images and start containers
    docker compose up -d
}
