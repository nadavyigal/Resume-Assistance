@echo off
echo Resume Assistance - GitHub Upload Helper
echo =======================================
echo.

echo Step 1: Check if Git is installed...
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Git is not installed or not in PATH.
    echo Please install Git from https://git-scm.com/downloads and try again.
    goto :EOF
)
echo Git is installed. Proceeding...
echo.

echo Step 2: Let's create your repository on GitHub.
echo Please ensure you've created a repository named "Resume-Assistance" on GitHub.
echo.
set /p REPO_URL="Enter the repository URL (e.g., https://github.com/yourusername/Resume-Assistance.git): "
if "%REPO_URL%"=="" (
    echo ERROR: Repository URL cannot be empty.
    goto :EOF
)
echo.

echo Step 3: Initialize Git repository...
git init
echo.

echo Step 4: Adding all project files...
git add .
echo.

echo Step 5: Creating initial commit...
git commit -m "Initial commit: Resume Assistant application"
echo.

echo Step 6: Setting up remote repository...
git remote add origin %REPO_URL%
echo.

echo Step 7: Pushing to GitHub...
git push -u origin main
if %ERRORLEVEL% neq 0 (
    echo Failed with main branch, trying master...
    git push -u origin master
)
echo.

echo Step 8: Cleanup...
echo If you see any errors above, please check the GitHub repository URL and try again.
echo If successful, your code is now on GitHub at %REPO_URL%
echo.

echo Process completed!
echo.
pause