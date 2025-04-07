# Resume Assistant Setup Script
# This script helps set up and run the Resume Assistant project on Windows

# Error handling
$ErrorActionPreference = "Stop"

function Check-Command {
    param (
        [string]$Command
    )
    
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Setup-Backend {
    Write-Host "Setting up the backend..." -ForegroundColor Cyan
    
    # Navigate to backend directory
    Push-Location backend
    
    # Create virtual environment if it doesn't exist
    if (-not (Test-Path "venv")) {
        Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
        python -m venv venv
    }
    
    # Activate virtual environment
    Write-Host "Activating virtual environment..." -ForegroundColor Yellow
    & .\venv\Scripts\Activate.ps1
    
    # Install dependencies
    Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
    
    # Check if .env file exists
    if (-not (Test-Path ".env")) {
        Write-Host "Creating .env file from example..." -ForegroundColor Yellow
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" -Destination ".env"
            Write-Host "Please edit the .env file to add your OpenAI API key." -ForegroundColor Red
        } else {
            Write-Host "Warning: .env.example not found. Please create a .env file manually." -ForegroundColor Red
        }
    }
    
    # Download spaCy model
    Write-Host "Downloading spaCy model..." -ForegroundColor Yellow
    python -m spacy download en_core_web_sm
    
    # Return to original directory
    Pop-Location
    
    Write-Host "Backend setup complete!" -ForegroundColor Green
}

function Setup-Frontend {
    Write-Host "Setting up the frontend..." -ForegroundColor Cyan
    
    # Navigate to frontend directory
    Push-Location frontend
    
    # Install dependencies
    Write-Host "Installing Node.js dependencies..." -ForegroundColor Yellow
    npm install
    
    # Return to original directory
    Pop-Location
    
    Write-Host "Frontend setup complete!" -ForegroundColor Green
}

function Start-Backend {
    Write-Host "Starting the backend server..." -ForegroundColor Cyan
    
    # Navigate to backend directory
    Push-Location backend
    
    # Activate virtual environment
    & .\venv\Scripts\Activate.ps1
    
    # Start the server
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& {. .\venv\Scripts\Activate.ps1; python app.py}"
    
    # Return to original directory
    Pop-Location
}

function Start-Frontend {
    Write-Host "Starting the frontend server..." -ForegroundColor Cyan
    
    # Navigate to frontend directory
    Push-Location frontend
    
    # Start the server
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "npm start"
    
    # Return to original directory
    Pop-Location
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

$pythonInstalled = Check-Command "python"
$nodeInstalled = Check-Command "node"
$npmInstalled = Check-Command "npm"

if (-not $pythonInstalled) {
    Write-Host "Error: Python is not installed or not in PATH. Please install Python 3.8+ and try again." -ForegroundColor Red
    exit 1
}

if (-not $nodeInstalled -or -not $npmInstalled) {
    Write-Host "Error: Node.js or npm is not installed or not in PATH. Please install Node.js 14+ and try again." -ForegroundColor Red
    exit 1
}

# Main menu
function Show-Menu {
    Clear-Host
    Write-Host "Resume Assistant Setup" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Full Setup (Backend & Frontend)"
    Write-Host "2. Setup Backend Only"
    Write-Host "3. Setup Frontend Only"
    Write-Host "4. Run Backend"
    Write-Host "5. Run Frontend"
    Write-Host "6. Run Both (Backend & Frontend)"
    Write-Host "7. Exit"
    Write-Host ""
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-7)"
    
    switch ($choice) {
        "1" {
            Setup-Backend
            Setup-Frontend
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Setup-Backend
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Setup-Frontend
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Start-Backend
            Write-Host "Backend server started in a new window." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Start-Frontend
            Write-Host "Frontend server started in a new window." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "6" {
            Start-Backend
            Start-Frontend
            Write-Host "Both servers started in new windows." -ForegroundColor Green
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "7" {
            Write-Host "Exiting script. Goodbye!" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
            Write-Host "Press any key to continue..." -ForegroundColor Cyan
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)