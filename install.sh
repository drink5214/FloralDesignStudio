#!/bin/bash

# Check Python version
python3 --version >/dev/null 2>&1 || { echo "Python 3 is required but not installed. Aborting." >&2; exit 1; }

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create necessary directories
mkdir -p logs
mkdir -p build_output

# Copy environment configuration
cp .env.example .env

echo "Please update the .env file with your specific configurations."
echo "Installation complete! You can now configure the launchd service."