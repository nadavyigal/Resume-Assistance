# Resume Assistant

A full-stack application designed to help job seekers create tailored, optimized resumes by analyzing job descriptions and extracting relevant skills and qualifications from existing CVs.

## Features

- **CV Parsing**: Extract key information from uploaded PDF resumes
- **Job Scraping**: Analyze job postings to identify required skills and qualifications
- **Smart Resume Generation**: Create tailored resumes that highlight relevant experience
- **AI-Powered Optimization**: Leverage OpenAI to enhance resume content based on job requirements
- **Interactive Feedback**: Adjust emphasis and content with an intuitive interface
- **PDF Download**: Generate professional-looking resume PDFs for immediate use
- **Session Management**: Securely store resume data temporarily using Redis

## Project Structure

- `backend/` - Flask API with CV parsing, job scraping, and resume generation
- `frontend/` - React application with intuitive UI for resume customization

## Setup Instructions

### Prerequisites

- Python 3.8+
- Node.js 14+
- OpenAI API key
- Redis (optional)

### Backend (Flask)

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

5. Set up environment variables by creating a `.env` file based on `.env.example`

6. Download the spaCy model:
   ```
   python -m spacy download en_core_web_sm
   ```

7. Run the development server:
   ```
   python app.py
   ```

## Demo Mode

If you don't have an OpenAI API key, the application will run in demo mode with limited functionality.

## License

MIT