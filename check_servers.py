#!/usr/bin/env python3
"""
Check if the Resume Assistant servers are running.
This script attempts to connect to the backend and frontend servers
and reports their status.
"""

import requests
import sys
import time
from urllib.parse import urlparse
import socket

def check_port_open(host, port, timeout=2):
    """Check if a port is open on the host."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except:
        return False

def check_url(url, timeout=2):
    """Check if a URL is accessible."""
    try:
        response = requests.get(url, timeout=timeout)
        status = response.status_code
        return status < 400, status
    except requests.RequestException as e:
        return False, str(e)

def main():
    """Check if the servers are running and display their status."""
    backend_url = "http://localhost:5000/status"
    frontend_port = 3000
    
    print("Resume Assistant Server Status Check")
    print("===================================")
    
    # Check backend
    print("\nChecking Backend (Flask) server...")
    
    # First check if port is open
    backend_port_open = check_port_open("localhost", 5000)
    if not backend_port_open:
        print("❌ Backend server is NOT running (port 5000 is closed)")
    else:
        print("✅ Backend server port is open (5000)")
        
        # Try to get a response from the API
        is_up, status = check_url(backend_url)
        if is_up:
            print(f"✅ Backend API is responding (status {status})")
        else:
            print(f"⚠️ Backend port is open but API is not responding properly: {status}")
    
    # Check frontend
    print("\nChecking Frontend (React) server...")
    frontend_port_open = check_port_open("localhost", frontend_port)
    
    if not frontend_port_open:
        print("❌ Frontend server is NOT running (port 3000 is closed)")
    else:
        print("✅ Frontend server is running (port 3000 is open)")
    
    # Summary
    print("\nSummary:")
    if backend_port_open and frontend_port_open:
        print("✅ Both servers appear to be running correctly.")
    elif backend_port_open:
        print("⚠️ Backend is running, but frontend is not available.")
        print("   Run 'run_frontend.bat' to start the frontend server.")
    elif frontend_port_open:
        print("⚠️ Frontend is running, but backend is not available.")
        print("   Run 'run_backend.bat' to start the backend server.")
    else:
        print("❌ Neither server is running.")
        print("   Run 'run_backend.bat' and 'run_frontend.bat' to start the servers.")
    
    print("\nNote: If you've recently started the servers, they might still be initializing.")
    print("Wait a moment and run this check again.")

if __name__ == "__main__":
    main()