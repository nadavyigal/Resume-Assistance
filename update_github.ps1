# Resume Assistant - GitHub Update Script
# This script helps update the GitHub repository with the deployment files

# Error handling
$ErrorActionPreference = "Stop"

function Write-UpdateLog {
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
}

# Check if Git is installed
function Check-Git {
    Write-UpdateLog "Checking Git installation..."
    
    $gitInstalled = $null -ne (Get-Command "git" -ErrorAction SilentlyContinue)
    
    if (-not $gitInstalled) {
        Write-UpdateLog "Git is not installed. Please install Git from https://git-scm.com/downloads" -Type "ERROR"
        exit 1
    }
    
    Write-UpdateLog "Git is installed" -Type "SUCCESS"
}

# Check if repository is initialized
function Check-Repository {
    Write-UpdateLog "Checking Git repository status..."
    
    if (-not (Test-Path ".git")) {
        Write-UpdateLog "Git repository not initialized." -Type "ERROR"
        Write-UpdateLog "Please run 'upload_to_github.bat' first to initialize the repository." -Type "ERROR"
        exit 1
    }
    
    Write-UpdateLog "Git repository exists" -Type "SUCCESS"
}

# List deployment files to stage
function Get-DeploymentFiles {
    Write-UpdateLog "Identifying deployment files to update..."
    
    $deploymentFiles = @(
        "render.yaml",
        "deploy.ps1",
        "deploy_backend.ps1",
        "deploy_frontend.ps1",
        "DEPLOYMENT_README.md",
        "frontend/vercel.json",
        "frontend/.env.production",
        "frontend/src/config.js",
        "@plan.md",
        "@current_problems.md"
    )
    
    $existingFiles = @()
    
    foreach ($file in $deploymentFiles) {
        if (Test-Path $file) {
            $existingFiles += $file
            Write-UpdateLog "Found $file" -Type "INFO"
        } else {
            Write-UpdateLog "File not found: $file" -Type "WARNING"
        }
    }
    
    return $existingFiles
}

# Stage all deployment files
function Stage-Files {
    param (
        [array]$Files
    )
    
    Write-UpdateLog "Staging deployment files for commit..."
    
    foreach ($file in $Files) {
        Write-UpdateLog "Staging $file" -Type "INFO"
        git add $file
    }
    
    Write-UpdateLog "Files staged successfully" -Type "SUCCESS"
}

# Commit changes
function Commit-Changes {
    Write-UpdateLog "Committing changes..."
    
    $commitMessage = "Add deployment configuration and scripts"
    
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "Failed to commit changes. Please check if there are any changes to commit." -Type "ERROR"
        exit 1
    }
    
    Write-UpdateLog "Changes committed with message: '$commitMessage'" -Type "SUCCESS"
}

# Push to GitHub
function Push-Changes {
    Write-UpdateLog "Pushing changes to GitHub..."
    
    # Check if upstream branch is set
    $upstreamSet = git branch -vv | Select-String "\[origin/"
    
    if (-not $upstreamSet) {
        Write-UpdateLog "No upstream branch set. Setting upstream branch..." -Type "WARNING"
        git push --set-upstream origin main
    } else {
        git push origin
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-UpdateLog "Failed to push changes to GitHub. Please check your connection and permissions." -Type "ERROR"
        Write-UpdateLog "You might need to create a repository on GitHub first." -Type "ERROR"
        Write-UpdateLog "Run 'upload_to_github.bat' to create and set up a new repository." -Type "ERROR"
        exit 1
    }
    
    Write-UpdateLog "Changes pushed to GitHub successfully" -Type "SUCCESS"
}

# Main function
function Update-GitHub {
    Write-UpdateLog "Starting GitHub update process..." -Type "INFO"
    
    Check-Git
    Check-Repository
    
    $filesToStage = Get-DeploymentFiles
    
    if ($filesToStage.Count -eq 0) {
        Write-UpdateLog "No deployment files found to update. Process aborted." -Type "ERROR"
        exit 1
    }
    
    Stage-Files -Files $filesToStage
    Commit-Changes
    Push-Changes
    
    Write-UpdateLog "GitHub repository updated successfully with deployment files!" -Type "SUCCESS"
    Write-UpdateLog "Now your project is ready for deployment to Render and Vercel."
}

# Execute the update
Update-GitHub