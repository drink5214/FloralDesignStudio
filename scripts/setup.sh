#!/bin/bash

# Setup script for Windsurf-Xcode Integration

# Make install script executable
chmod +x install.sh

# Install launchd service
cp com.windsurf.integration.plist ~/Library/LaunchAgents/
launchctl unload ~/Library/LaunchAgents/com.windsurf.integration.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.windsurf.integration.plist

# Create environment file
cp .env.example .env

# Create required directories
mkdir -p logs
mkdir -p build_output

# Install dependencies
python3 -m pip install watchdog==3.0.0 python-dotenv==1.0.0 requests==2.31.0 pytest==7.4.3 \
    pytest-mock==3.12.0 pytest-cov==4.1.0 asyncio==3.4.3 aiohttp==3.9.1 pyyaml==6.0.1 \
    tenacity==8.2.3 colorlog==6.7.0

echo "Setup complete! Please edit .env file with your configuration values."