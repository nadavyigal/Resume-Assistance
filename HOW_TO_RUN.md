# How to Run Resume Assistant

This guide provides step-by-step instructions for setting up and running the Resume Assistant application.

## Prerequisites

Ensure you have the following installed:
- Python 3.8+
- Node.js 14+
- Git (for cloning the repository)

## Quick Start (Windows)

If you're on Windows, you can use the included batch files and setup script:

1. Run the interactive setup script:
   ```
   .\setup_project.ps1
   ```
   This will guide you through setting up the entire project or running individual components.

Alternatively, you can use the batch files:

2. Start the backend:
   ```
   .\run_backend.bat
   ```

3. Check if servers are running:
   ```
   python check_servers.py
   ```

## Manual Setup

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   ```

3. Activate the virtual environment:
   - Windows: `venv\Scripts\activate`
   - macOS/Linux: `source venv/bin/activate`

4. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

5. Set up environment variables:
   ```
   # Windows
   copy .env.example .env
   
   # macOS/Linux
   cp .env.example .env
   ```
   
   Edit the `.env` file to add your OpenAI API key.

6. Download the spaCy model:
   ```
   python -m spacy download en_core_web_sm
   ```

7. Run the backend server:
   ```
   python run.py
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npm start
   ```

## Verification

To check if all servers are running properly, use:
```
python check_servers.py
```

## Using the Application

1. Open your browser and go to `http://localhost:3000`
2. Upload your resume PDF
3. Enter a job description URL or paste in the job description text
4. The application will analyze your resume against the job description
5. Review the optimized resume and download the enhanced PDF

## Demo Mode

If you don't have an OpenAI API key, the application will run in demo mode, which:
- Provides simulated AI responses
- Has limited functionality
- Uses hard-coded patterns for skill matching

To use the full features, add your OpenAI API key to the `.env` file.

## Troubleshooting

If you encounter issues:

1. Check that both servers are running with `python check_servers.py`
2. Verify that your `.env` file is properly configured
3. Check the console for error messages
4. Ensure all dependencies are installed correctly

Common issues:
- Port conflicts: The backend uses port 5000 and the frontend uses port 3000. If these ports are in use by other applications, you may need to modify the port configuration.
- API key issues: If you see "DEMO MODE" in the console, your OpenAI API key is not properly configured.
- Missing dependencies: Make sure you've run all the setup steps including installing Python and Node.js dependencies.