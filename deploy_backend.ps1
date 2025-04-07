# Resume Assistant Backend Deployment Script
# This script helps prepare and deploy the backend for Render

# Error handling
$ErrorActionPreference = "Stop"

# Log function for deployment steps
function Write-DeploymentLog {
    param (
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Type) {
        "INFO" { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor $color
    
    # Also log to backend/yolo_log.txt with error handling
    $logMessage = "[$timestamp] DEPLOY: $Message"
    try {
        Add-Content -Path "backend/yolo_log.txt" -Value $logMessage
    } catch {
        Write-Host "Warning: Could not write to log file. Continuing without logging." -ForegroundColor Yellow
    }
}

# Verify all necessary files exist
function Verify-DeploymentFiles {
    Write-DeploymentLog "Verifying deployment files..."
    
    $requiredFiles = @(
        "backend/app.py",
        "backend/requirements.txt",
        "render.yaml"
    )
    
    $allFilesExist = $true
    
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            Write-DeploymentLog "Missing required file: $file" -Type "ERROR"
            $allFilesExist = $false
        }
    }
    
    if (-not $allFilesExist) {
        Write-DeploymentLog "Deployment preparation failed due to missing files" -Type "ERROR"
        exit 1
    }
    
    Write-DeploymentLog "All required files are present" -Type "SUCCESS"
}

# Check if gunicorn is in requirements.txt
function Check-Requirements {
    Write-DeploymentLog "Checking requirements.txt for deployment dependencies..."
    
    $requirementsContent = Get-Content "backend/requirements.txt"
    
    if (-not ($requirementsContent -match "gunicorn")) {
        Write-DeploymentLog "Adding gunicorn to requirements.txt for production deployment" -Type "WARNING"
        Add-Content -Path "backend/requirements.txt" -Value "gunicorn==21.2.0"
    }
    
    Write-DeploymentLog "Requirements check complete" -Type "SUCCESS"
}

# Create necessary directories
function Prepare-Directories {
    Write-DeploymentLog "Preparing directories for deployment..."
    
    # Ensure temp directory exists
    if (-not (Test-Path "backend/temp")) {
        Write-DeploymentLog "Creating temp directory for PDF processing"
        New-Item -Path "backend/temp" -ItemType Directory -Force | Out-Null
    }
    
    # Ensure uploads directory exists
    if (-not (Test-Path "backend/uploads")) {
        Write-DeploymentLog "Creating uploads directory for file storage"
        New-Item -Path "backend/uploads" -ItemType Directory -Force | Out-Null
    }
    
    Write-DeploymentLog "Directory preparation complete" -Type "SUCCESS"
}

# Verify CORS is properly configured
function Check-CORS {
    Write-DeploymentLog "Checking CORS configuration..."
    
    $appContent = Get-Content "backend/app.py" -Raw
    
    if (-not ($appContent -match "CORS\(app")) {
        Write-DeploymentLog "CORS might not be properly configured in app.py" -Type "WARNING"
        Write-DeploymentLog "Please ensure CORS is properly set up to allow frontend connections" -Type "WARNING"
    } else {
        Write-DeploymentLog "CORS configuration found" -Type "SUCCESS"
    }
}

# Provide instructions for Render deployment
function Show-DeploymentInstructions {
    Write-DeploymentLog "Backend deployment preparation complete!" -Type "SUCCESS"
    Write-Host ""
    Write-Host "Next steps for deploying to Render:" -ForegroundColor Green
    Write-Host "1. Push your code to GitHub if you haven't already" -ForegroundColor White
    Write-Host "2. Log in to Render (https://render.com)" -ForegroundColor White
    Write-Host "3. Click 'New' and select 'Blueprint'" -ForegroundColor White
    Write-Host "4. Connect your GitHub repository" -ForegroundColor White
    Write-Host "5. Render will detect your render.yaml file and set up services" -ForegroundColor White
    Write-Host "6. Review the configuration and click 'Apply'" -ForegroundColor White
    Write-Host "7. Wait for the deployment to complete" -ForegroundColor White
    Write-Host "8. Note your API URL (e.g., https://resume-assistant-api.onrender.com)" -ForegroundColor White
    Write-Host ""
    Write-Host "Important: After deployment, add your OpenAI API key in the Render dashboard" -ForegroundColor Yellow
    Write-Host "Environment Variables section" -ForegroundColor Yellow
}

# Main deployment preparation process
function Prepare-Deployment {
    Write-DeploymentLog "Starting backend deployment preparation..." -Type "INFO"
    
    Verify-DeploymentFiles
    Check-Requirements
    Prepare-Directories
    Check-CORS
    
    Show-DeploymentInstructions
}

# Execute the deployment preparation
Prepare-Deployment