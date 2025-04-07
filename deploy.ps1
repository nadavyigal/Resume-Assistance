# Resume Assistant Deployment Script
# This script helps prepare and deploy the Resume Assistant application

# Error handling
$ErrorActionPreference = "Stop"

# Function to display the menu
function Show-Menu {
    Clear-Host
    Write-Host "Resume Assistant Deployment" -ForegroundColor Green
    Write-Host "==========================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Deploy Backend to Render"
    Write-Host "2. Deploy Frontend to Vercel"
    Write-Host "3. Deploy Both (Backend & Frontend)"
    Write-Host "4. Update Frontend API URL"
    Write-Host "5. Exit"
    Write-Host ""
}

# Capture the API URL if specified as a command-line argument
$backendUrl = $null
if ($args.Count -gt 0) {
    $backendUrl = $args[0]
}

# Main menu loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" {
            # Run backend deployment script
            Write-Host "Preparing backend for deployment to Render..." -ForegroundColor Cyan
            & .\deploy_backend.ps1
            
            Write-Host ""
            Write-Host "Backend deployment preparation complete." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            # Run frontend deployment script with API URL if provided
            Write-Host "Preparing frontend for deployment to Vercel..." -ForegroundColor Cyan
            if ($backendUrl) {
                & .\deploy_frontend.ps1 $backendUrl
            } else {
                & .\deploy_frontend.ps1
            }
            
            Write-Host ""
            Write-Host "Frontend deployment preparation complete." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            # Run both deployment scripts
            Write-Host "Preparing both backend and frontend for deployment..." -ForegroundColor Cyan
            
            # First deploy backend
            Write-Host "1. Preparing backend for deployment to Render..." -ForegroundColor Cyan
            & .\deploy_backend.ps1
            
            # Prompt for backend URL after backend deployment preparation
            Write-Host ""
            $newBackendUrl = Read-Host "Enter your Backend API URL for frontend configuration (or press Enter for default)"
            
            if ([string]::IsNullOrWhiteSpace($newBackendUrl)) {
                $newBackendUrl = "https://resume-assistant-api.onrender.com"
            }
            
            # Then deploy frontend with the provided backend URL
            Write-Host ""
            Write-Host "2. Preparing frontend for deployment to Vercel..." -ForegroundColor Cyan
            & .\deploy_frontend.ps1 $newBackendUrl
            
            Write-Host ""
            Write-Host "Both backend and frontend deployment preparation complete." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            # Update frontend API URL only
            Write-Host "Updating frontend API URL..." -ForegroundColor Cyan
            
            $newBackendUrl = Read-Host "Enter your Backend API URL"
            
            if (-not [string]::IsNullOrWhiteSpace($newBackendUrl)) {
                Set-Content -Path "frontend/.env.production" -Value "REACT_APP_API_URL=$newBackendUrl" -Force
                
                # Make sure we update the global variable too
                $backendUrl = $newBackendUrl
                
                Write-Host "API URL updated to: $newBackendUrl" -ForegroundColor Green
                
                # Log to yolo_log.txt with error handling
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logMessage = "[$timestamp] DEPLOY: Updated frontend API URL to $newBackendUrl"
                try {
                    Add-Content -Path "backend/yolo_log.txt" -Value $logMessage
                } catch {
                    Write-Host "Warning: Could not write to log file. Continuing without logging." -ForegroundColor Yellow
                }
            } else {
                Write-Host "No URL provided. API URL not updated." -ForegroundColor Yellow
            }
            
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Write-Host "Exiting deployment script. Goodbye!" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)