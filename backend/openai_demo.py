"""
OpenAI Integration Demo for Resume Assistant

This script demonstrates how to use the OpenAI API to enhance resume generation:
1. Improving resume summaries
2. Tailoring skills to job descriptions
3. Enhancing job descriptions
4. Providing pro tips for resume improvement

The script will run in demo mode if no valid OpenAI API key is provided.
"""

import os
import sys
import json
import re

# Load environment variables
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    print("Error: python-dotenv not installed. Run 'pip install python-dotenv'")
    sys.exit(1)

# Check for OpenAI API key
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
USE_DEMO_MODE = not OPENAI_API_KEY or OPENAI_API_KEY in ('your_openai_api_key_here', 'your-openai-api-key-here')

# HR Bot system instructions
HR_BOT_SYSTEM_INSTRUCTIONS = """You are HR Bot, an intelligent AI-powered assistant embedded within our resume optimization platform. Your role is to help job seekers maximize their opportunities by:

• Analyzing job descriptions to extract key requirements and matching them against a user's CV.
• Rewriting and reorganizing CV content for clarity, relevance, and ATS compliance.
• Generating actionable, industry-specific pro tips for resume improvement and interview preparation.

You are integrated with our updated components—including JobList, CVPreview, and ProTips—and operate via a dedicated API route that communicates with OpenAI's GPT. When a user submits a request:
  - For job matching, analyze the provided job description, extract critical skills and requirements, and compare them with the candidate's experience.
  - For CV rewriting, review and optimize the CV content by reordering sections, rephrasing text, and ensuring the document is both human- and ATS-friendly.
  - For pro tips generation, deliver concise, tailored advice that helps users enhance their resume and prepare for job applications.

Ensure that your responses are clear, professional, and customized to the user's context. If a request is ambiguous, ask clarifying questions before proceeding. Use your full AI capabilities to generate content that is insightful, precise, and useful."""

if USE_DEMO_MODE:
    print("Notice: Using DEMO MODE because no valid OpenAI API key was found in .env file")
    print("To use actual OpenAI API, add your API key to the .env file: OPENAI_API_KEY=your-actual-key")
else:
    # Import OpenAI
    try:
        import openai
        from openai import OpenAI
        client = OpenAI(api_key=OPENAI_API_KEY)
    except ImportError:
        print("Error: OpenAI package not installed. Run 'pip install openai'")
        sys.exit(1)

def enhance_resume_summary(basic_summary, job_description):
    """Generate an enhanced professional summary for a resume based on a job description."""
    try:
        print(f"Enhancing resume summary for job...")
        
        if USE_DEMO_MODE:
            print("DEMO MODE: Generating simulated response...")
            
            # Create a simulated enhanced summary based on key terms in the job description
            keywords = ["React", "TypeScript", "CSS", "responsive", "Redux", "GraphQL", "testing"]
            matched_keywords = [kw for kw in keywords if kw.lower() in job_description.lower()]
            
            if "Senior" in job_description or "Sr" in job_description:
                experience_level = "senior-level"
            elif "Junior" in job_description or "Jr" in job_description:
                experience_level = "junior-level"
            else:
                experience_level = "mid-level"
                
            if matched_keywords:
                keyword_phrase = ", ".join(matched_keywords[:3])
                return f"Accomplished {experience_level} software developer with 5+ years of experience specializing in {keyword_phrase}. Proven track record of building responsive, user-friendly web applications with a focus on code quality and performance optimization."
            else:
                return f"Versatile {experience_level} developer with extensive experience in web development and a passion for creating intuitive, high-performance applications. Combines strong technical skills with collaborative problem-solving to deliver outstanding user experiences."
        
        # If not in demo mode, use actual OpenAI API
        prompt = f"""
        Create a professional and tailored resume summary based on the following information:

        Basic Summary: {basic_summary}
        
        Job Description: {job_description}
        
        Create a professional summary that:
        1. Is 2-3 sentences long
        2. Highlights relevant skills and experience
        3. Is tailored to the specific job description
        4. Uses professional, confident language
        5. Avoids clichés and generic statements
        
        Return ONLY the enhanced summary text with no additional commentary.
        """
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": HR_BOT_SYSTEM_INSTRUCTIONS},
                {"role": "user", "content": prompt}
            ],
            max_tokens=150,
            temperature=0.7
        )
        
        enhanced_summary = response.choices[0].message.content.strip()
        return enhanced_summary
        
    except Exception as e:
        print(f"Error enhancing resume summary: {str(e)}")
        return basic_summary

def prioritize_skills(candidate_skills, job_description):
    """Prioritize and enhance skills based on job description."""
    try:
        print(f"Prioritizing {len(candidate_skills)} skills based on job description...")
        
        if USE_DEMO_MODE:
            print("DEMO MODE: Generating simulated response...")
            
            # Create simulated prioritized skills
            high_priority_terms = ["React", "TypeScript", "Redux", "responsive", "testing"]
            medium_priority_terms = ["JavaScript", "CSS", "HTML", "REST", "Git"]
            
            prioritized = []
            for skill in candidate_skills:
                skill_name = skill
                
                # Determine priority based on presence in the job description and key terms
                job_desc_lower = job_description.lower()
                skill_lower = skill.lower()
                
                # First check if the skill itself is mentioned in the job description (direct match)
                if skill_lower in job_desc_lower:
                    # Direct mention in job description is high priority
                    priority = "high"
                # Then check if it matches any high priority terms
                elif any(term.lower() in skill_lower for term in high_priority_terms):
                    # Check if the term is also in the job description
                    if any(term.lower() in job_desc_lower for term in high_priority_terms if term.lower() in skill_lower):
                        priority = "high"
                    else:
                        priority = "medium"
                # Then check for medium priority matches
                elif any(term.lower() in skill_lower for term in medium_priority_terms):
                    # Check if the term is also in the job description
                    if any(term.lower() in job_desc_lower for term in medium_priority_terms if term.lower() in skill_lower):
                        priority = "medium"
                    else:
                        priority = "low"
                else:
                    priority = "low"
                    
                prioritized.append({"name": skill_name, "priority": priority})
                
            return prioritized
            
        # If not in demo mode, use actual OpenAI API
        skills_json = json.dumps(candidate_skills)
        
        prompt = f"""
        Analyze this job description and prioritize the candidate's skills:

        Job Description: {job_description}
        
        Candidate Skills: {skills_json}
        
        For each skill, determine:
        1. Relevance to the job (high, medium, low)
        2. How to phrase it professionally
        
        Return a JSON array of skills with each skill having:
        - name: The skill name (possibly rephrased)
        - priority: "high", "medium", or "low" based on relevance
        
        Format: [{{"name": "skill name", "priority": "high|medium|low"}}, ...]
        """
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": HR_BOT_SYSTEM_INSTRUCTIONS},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            response_format={"type": "json_object"}
        )
        
        result = response.choices[0].message.content.strip()
        prioritized_skills = json.loads(result)
        return prioritized_skills.get("skills", [])
        
    except Exception as e:
        print(f"Error prioritizing skills: {str(e)}")
        # Return original skills with medium priority as fallback
        return [{"name": skill, "priority": "medium"} for skill in candidate_skills]

def get_resume_pro_tips(cv_content, job_description):
    """Generate professional tips for improving a resume based on job description."""
    try:
        print("Generating pro tips for resume improvement...")
        
        if USE_DEMO_MODE:
            print("DEMO MODE: Generating simulated pro tips...")
            
            # Analyze CV and job description for personalized tips
            
            # Extract key skills mentioned in job description
            job_skills = []
            skill_patterns = [
                r'\b(React|Angular|Vue|TypeScript|JavaScript|Node\.js)\b',
                r'\b(HTML5|CSS3|SCSS|LESS|Tailwind|Bootstrap)\b',
                r'\b(Redux|GraphQL|REST API|Axios|Fetch)\b',
                r'\b(testing|Jest|Cypress|Selenium|unit testing)\b',
                r'\b(responsive|mobile-first|cross-browser)\b',
                r'\b(Git|CI/CD|Agile|Scrum|DevOps)\b'
            ]
            
            for pattern in skill_patterns:
                matches = re.finditer(pattern, job_description, re.IGNORECASE)
                for match in matches:
                    skill = match.group(1)
                    if skill and skill.lower() not in [s.lower() for s in job_skills]:
                        job_skills.append(skill)
            
            # Check missing key skills
            cv_has_skills = []
            for skill in job_skills:
                if re.search(r'\b' + re.escape(skill) + r'\b', cv_content, re.IGNORECASE):
                    cv_has_skills.append(skill)
            
            missing_skills = [skill for skill in job_skills if skill not in cv_has_skills]
            
            # Create personalized tips
            tips = []
            
            # Tip 1: Add a professional summary if missing
            if not re.search(r'(summary|profile|objective)', cv_content, re.IGNORECASE):
                tips.append(f"Add a professional summary at the top of your resume highlighting your expertise in {', '.join(job_skills[:3]) if job_skills else 'frontend development'}")
            
            # Tip 2: Address missing key skills
            if missing_skills:
                tips.append(f"Add experience with {', '.join(missing_skills[:3])} to your skills section as these are specifically mentioned in the job description")
            
            # Tip 3: Quantify achievements
            if not re.search(r'\b(\d+%|\d+ percent|increased|decreased|improved|reduced|saved|generated)\b', cv_content, re.IGNORECASE):
                tips.append("Quantify your achievements with metrics (e.g., 'Improved application performance by 30%' instead of 'Improved application performance')")
            
            # Tip 4: Use action verbs
            if not re.search(r'\b(developed|implemented|created|designed|managed|led|coordinated|analyzed)\b', cv_content, re.IGNORECASE):
                tips.append("Start your experience bullet points with strong action verbs like 'Developed', 'Implemented', or 'Designed'")
            
            # Tip 5: ATS optimization
            tips.append(f"Ensure your resume includes these key keywords from the job description: {', '.join(job_skills[:5]) if job_skills else 'web development, frontend, JavaScript'}")
            
            # Add general tips if we have fewer than 5 specific ones
            general_tips = [
                "Keep your resume to 1-2 pages maximum for optimal readability",
                "Tailor your resume for each job application to highlight relevant experience",
                "Use a clean, professional design with consistent formatting",
                "Include a GitHub link or portfolio showcasing your projects",
                "Remove outdated skills or irrelevant experience"
            ]
            
            while len(tips) < 5:
                tips.append(general_tips[len(tips) - 1])
            
            return tips[:5]
        
        # If not in demo mode, use actual OpenAI API
        prompt = f"""
        Review this CV content and job description to provide professional tips for resume improvement:

        CV Content:
        {cv_content}
        
        Job Description:
        {job_description}
        
        Generate 5 specific, actionable tips to improve the resume for this job. Focus on:
        1. Keyword optimization for ATS systems
        2. Content structure and formatting
        3. Skills highlighting and prioritization
        4. Experience presentation
        5. Overall impact and readability
        
        Return ONLY a numbered list of 5 tips without additional commentary.
        """
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": HR_BOT_SYSTEM_INSTRUCTIONS},
                {"role": "user", "content": prompt}
            ],
            max_tokens=400,
            temperature=0.6
        )
        
        result = response.choices[0].message.content.strip().split('\n')
        # Clean up and format the tips consistently
        formatted_tips = []
        for tip in result:
            # Remove numbers, asterisks, dashes, etc. at the beginning of the tip
            cleaned_tip = re.sub(r'^[\d\.\)\-\*\s]+', '', tip).strip()
            if cleaned_tip:
                formatted_tips.append(cleaned_tip)
                
        return formatted_tips[:5]  # Return maximum 5 tips
        
    except Exception as e:
        print(f"Error generating resume pro tips: {str(e)}")
        # Return generic tips as fallback
        return [
            "Tailor your resume to match the specific job description",
            "Quantify your achievements with specific metrics",
            "Use industry-relevant keywords throughout your resume",
            "Focus on your most relevant skills and experience",
            "Ensure your resume is free of errors and professionally formatted"
        ]

def optimize_cv_content(cv_content, job_description):
    """Optimize CV content based on job description."""
    try:
        print("Optimizing CV content for the job...")
        
        if USE_DEMO_MODE:
            print("DEMO MODE: Generating simulated optimized CV...")
            
            # Extract key technologies from job description
            tech_patterns = [
                r'\b(React|Angular|Vue|TypeScript|JavaScript|Node\.js)\b',
                r'\b(Redux|GraphQL|REST API|Axios|Fetch)\b',
                r'\b(HTML5|CSS3|SCSS|LESS|Tailwind|Bootstrap)\b',
                r'\b(responsive|mobile-first|cross-browser)\b',
                r'\b(unit testing|Jest|Cypress|Selenium|TDD)\b',
                r'\b(Git|CI/CD|Agile|Scrum|DevOps)\b'
            ]
            
            job_techs = []
            for pattern in tech_patterns:
                matches = re.finditer(pattern, job_description, re.IGNORECASE)
                for match in matches:
                    tech = match.group(1)
                    if tech and tech.lower() not in [t.lower() for t in job_techs]:
                        job_techs.append(tech)
            
            # Check if we need to enhance the experience section
            lines = cv_content.split('\n')
            enhanced_cv = []
            in_experience = False
            experience_enhanced = False
            experience_section = []
            
            # Split CV into sections and enhance experience section
            for line in lines:
                if re.match(r'^experience|^work experience|^professional experience', line, re.IGNORECASE):
                    in_experience = True
                    enhanced_cv.append(line)
                elif in_experience and re.match(r'^education|^skills|^projects|^awards', line, re.IGNORECASE):
                    in_experience = False
                    
                    # Add job-specific achievements if not already enhanced
                    if not experience_enhanced and job_techs:
                        enhanced_cv.append("")  # Empty line
                        tech_mentions = ', '.join(job_techs[:3])
                        enhanced_cv.append(f"• Developed responsive user interfaces using {tech_mentions}, resulting in improved user engagement and 20% faster page load times")
                        enhanced_cv.append(f"• Collaborated with backend developers to integrate RESTful APIs, ensuring seamless data flow and optimal application performance")
                        enhanced_cv.append(f"• Implemented automated testing practices to enhance code quality and reduce bugs in production")
                        experience_enhanced = True
                    
                    enhanced_cv.append(line)
                else:
                    enhanced_cv.append(line)
            
            # Check for skills section and enhance if needed
            enhanced_content = '\n'.join(enhanced_cv)
            
            # Add missing skills if skills section exists
            skills_match = re.search(r'(?:skills|technical skills|core competencies)(?:.*?):(.*?)(?:^[a-z]+:|\Z)', enhanced_content, re.IGNORECASE | re.DOTALL | re.MULTILINE)
            if skills_match:
                skills_section = skills_match.group(1).strip()
                missing_techs = []
                
                for tech in job_techs:
                    if tech.lower() not in skills_section.lower():
                        missing_techs.append(tech)
                
                if missing_techs:
                    enhanced_content = enhanced_content.replace(
                        skills_section, 
                        skills_section + ", " + ", ".join(missing_techs)
                    )
            
            # Add professional summary at the beginning if none exists
            if not re.search(r'(summary|profile|objective):', enhanced_content, re.IGNORECASE):
                # Check if it's a senior role
                is_senior = "senior" in job_description.lower() or "sr." in job_description.lower()
                
                if is_senior:
                    summary = f"Professional Summary: Senior Software Developer with extensive experience in {', '.join(job_techs[:3]) if job_techs else 'web development'}. Proven track record of building scalable, efficient applications and leading development teams to deliver high-quality products.\n\n"
                else:
                    summary = f"Professional Summary: Dedicated Software Developer specializing in {', '.join(job_techs[:3]) if job_techs else 'web development'} with a passion for creating responsive, user-friendly applications. Committed to writing clean, maintainable code and staying current with industry best practices.\n\n"
                
                enhanced_content = summary + enhanced_content
            
            return enhanced_content
        
        # If not in demo mode, use actual OpenAI API
        prompt = f"""
        Optimize this CV content for the following job description:

        CV Content:
        {cv_content}
        
        Job Description:
        {job_description}
        
        Please:
        1. Reorder sections if needed (Professional Summary first, followed by Skills, Experience, Education)
        2. Add a tailored Professional Summary if none exists
        3. Highlight relevant skills and experience
        4. Add any important skills mentioned in the job description that are missing
        5. Ensure bullet points begin with strong action verbs
        6. Quantify achievements where possible
        
        Return the complete optimized CV content.
        """
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": HR_BOT_SYSTEM_INSTRUCTIONS},
                {"role": "user", "content": prompt}
            ],
            max_tokens=1500,
            temperature=0.4
        )
        
        optimized_cv = response.choices[0].message.content.strip()
        return optimized_cv
        
    except Exception as e:
        print(f"Error optimizing CV content: {str(e)}")
        return cv_content

# Demo usage
if __name__ == "__main__":
    # Sample data
    sample_summary = "Software developer with experience in web development."
    sample_skills = ["JavaScript", "React", "HTML", "CSS", "Node.js", "Express", "MongoDB", "Python", "Redux"]
    
    sample_job = """
    Senior Frontend Developer
    
    We're looking for a Senior Frontend Developer with strong React and TypeScript experience. 
    The ideal candidate should have experience with Redux, REST APIs, and responsive design.
    Responsibilities include:
    - Building responsive, cross-browser compatible UIs
    - Implementing state management using Redux
    - Working with backend teams to integrate APIs
    - Writing unit tests and maintaining code quality
    - Mentoring junior developers
    
    Required Skills:
    - 3+ years experience with React
    - Strong TypeScript skills
    - Experience with Redux and state management
    - HTML5, CSS3, and responsive design
    - Knowledge of REST APIs and data fetching
    - Git and CI/CD experience
    """
    
    sample_cv = """
    JOHN DOE
    Frontend Developer
    john.doe@email.com | (123) 456-7890 | github.com/johndoe
    
    Skills: JavaScript, React, HTML, CSS, Node.js, Express, MongoDB, Python
    
    Experience:
    
    Web Developer at TechCorp (2020-Present)
    • Developed web applications
    • Worked on frontend and backend systems
    • Collaborated with design team
    
    Junior Developer at StartupInc (2018-2020)
    • Assisted senior developers
    • Fixed bugs in existing applications
    • Implemented UI components
    
    Education:
    
    Bachelor of Science in Computer Science
    University of Technology (2014-2018)
    """
    
    # Demo enhance_resume_summary
    enhanced_summary = enhance_resume_summary(sample_summary, sample_job)
    print("\nEnhanced Summary:")
    print(enhanced_summary)
    
    # Demo prioritize_skills
    prioritized_skills = prioritize_skills(sample_skills, sample_job)
    print("\nPrioritized Skills:")
    for skill in prioritized_skills:
        print(f"- {skill['name']}: {skill['priority']} priority")
    
    # Demo get_resume_pro_tips
    pro_tips = get_resume_pro_tips(sample_cv, sample_job)
    print("\nPro Tips:")
    for i, tip in enumerate(pro_tips, 1):
        print(f"{i}. {tip}")
    
    # Demo optimize_cv_content
    optimized_cv = optimize_cv_content(sample_cv, sample_job)
    print("\nOptimized CV:")
    print(optimized_cv)