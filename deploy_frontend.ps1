# Resume Assistant Frontend Deployment Script
# This script helps prepare and deploy the frontend for Vercel

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
    Write-DeploymentLog "Verifying frontend deployment files..."
    
    $requiredFiles = @(
        "frontend/package.json",
        "frontend/src/App.js",
        "frontend/src/config.js",
        "frontend/vercel.json",
        "frontend/.env.production"
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
    
    Write-DeploymentLog "All required frontend files are present" -Type "SUCCESS"
}

# Make sure the API URL in .env.production is correct
function Check-ApiUrl {
    param (
        [string]$BackendUrl = $null
    )
    
    Write-DeploymentLog "Checking API URL configuration..."
    
    $envContent = Get-Content "frontend/.env.production" -Raw
    $currentUrl = if ($envContent -match "REACT_APP_API_URL=(.*)") { $Matches[1] } else { "" }
    
    if ([string]::IsNullOrWhiteSpace($BackendUrl)) {
        Write-Host "Current backend URL in .env.production: $currentUrl" -ForegroundColor Yellow
        $BackendUrl = Read-Host "Enter your backend API URL (or press Enter to keep current)"
        
        if ([string]::IsNullOrWhiteSpace($BackendUrl)) {
            $BackendUrl = $currentUrl
            Write-DeploymentLog "Keeping current API URL: $BackendUrl" -Type "INFO"
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($BackendUrl) -or $BackendUrl -eq "https://resume-assistant-api.onrender.com") {
        Write-DeploymentLog "Using default API URL. You'll need to update this after deploying the backend" -Type "WARNING"
        $BackendUrl = "https://resume-assistant-api.onrender.com"
    }
    
    # Update the .env.production file
    Set-Content -Path "frontend/.env.production" -Value "REACT_APP_API_URL=$BackendUrl" -Force
    
    Write-DeploymentLog "API URL set to: $BackendUrl" -Type "SUCCESS"
}

# Build the frontend for production
function Build-Frontend {
    Write-DeploymentLog "Building frontend for production..."
    
    # Navigate to frontend directory
    Push-Location frontend
    
    try {
        # Install dependencies if needed
        if (-not (Test-Path "node_modules")) {
            Write-DeploymentLog "Installing dependencies..."
            npm install
        }
        
        # Build the project
        Write-DeploymentLog "Running production build..."
        npm run build
        
        if (Test-Path "build") {
            Write-DeploymentLog "Frontend build successful" -Type "SUCCESS"
        } else {
            Write-DeploymentLog "Build folder not found. Build may have failed" -Type "ERROR"
        }
    }
    catch {
        Write-DeploymentLog "Build failed: $_" -Type "ERROR"
    }
    finally {
        # Return to original directory
        Pop-Location
    }
}

# Provide instructions for Vercel deployment
function Show-DeploymentInstructions {
    Write-DeploymentLog "Frontend deployment preparation complete!" -Type "SUCCESS"
    Write-Host ""
    Write-Host "Next steps for deploying to Vercel:" -ForegroundColor Green
    Write-Host "1. Push your code to GitHub if you haven't already" -ForegroundColor White
    Write-Host "2. Log in to Vercel (https://vercel.com)" -ForegroundColor White
    Write-Host "3. Click 'New Project'" -ForegroundColor White
    Write-Host "4. Import your GitHub repository" -ForegroundColor White
    Write-Host "5. Configure the project:" -ForegroundColor White
    Write-Host "   - Root Directory: frontend" -ForegroundColor White
    Write-Host "   - Build Command: npm run build (should be auto-detected)" -ForegroundColor White
    Write-Host "   - Output Directory: build (should be auto-detected)" -ForegroundColor White
    Write-Host "6. Add REACT_APP_API_URL environment variable with your backend URL" -ForegroundColor White
    Write-Host "7. Click 'Deploy'" -ForegroundColor White
    Write-Host ""
    Write-Host "Important: Make sure the backend URL in the environment variable is correct" -ForegroundColor Yellow
    Write-Host "and matches your deployed backend API on Render." -ForegroundColor Yellow
}

# Main deployment preparation process
function Prepare-Deployment {
    param (
        [string]$BackendUrl = $null
    )
    
    Write-DeploymentLog "Starting frontend deployment preparation..." -Type "INFO"
    
    Verify-DeploymentFiles
    Check-ApiUrl -BackendUrl $BackendUrl
    Build-Frontend
    
    Show-DeploymentInstructions
}

# Parse command-line arguments
$backendUrl = $null
if ($args.Count -gt 0) {
    $backendUrl = $args[0]
}

# Execute the deployment preparation
Prepare-Deployment -BackendUrl $backendUrl