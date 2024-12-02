#!/bin/bash

# Automated setup script for Windsurf-Xcode integration

echo "Starting Windsurf-Xcode integration setup..."

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed. Installing..."
    brew install python3
fi

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install watchdog==3.0.0 python-dotenv==1.0.0 requests==2.31.0 pytest==7.4.3 \
    pytest-mock==3.12.0 pytest-cov==4.1.0 asyncio==3.4.3 aiohttp==3.9.1 pyyaml==6.0.1 \
    tenacity==8.2.3 colorlog==6.7.0

# Create necessary directories
echo "Creating required directories..."
mkdir -p logs
mkdir -p build_output
mkdir -p config
mkdir -p agents
mkdir -p tests

# Setup environment configuration
echo "Setting up environment configuration..."
cat > .env << EOL
WINDSURF_API_KEY=your_api_key_here
WINDSURF_API_URL=https://api.windsurf.ai/v1
PROJECT_PATH=$(pwd)
XCODE_PROJECT_NAME=FloralDesignStudio
XCODE_SCHEME_NAME=FloralDesignStudio
BUILD_OUTPUT_PATH=$(pwd)/build_output
BUILD_CONFIGURATION=Debug
LOG_LEVEL=INFO
LOG_FILE_PATH=$(pwd)/logs/windsurf_integration.log
FILE_MONITOR_DEBOUNCE_TIME=1.0
BUILD_RETRY_LIMIT=3
ERROR_CORRECTION_TIMEOUT=300
EOL

# Create launchd service configuration
echo "Creating launchd service configuration..."
cat > com.windsurf.integration.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.windsurf.integration</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(pwd)/venv/bin/python3</string>
        <string>$(pwd)/main.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>$(pwd)/logs/windsurf_integration_error.log</string>
    <key>StandardOutPath</key>
    <string>$(pwd)/logs/windsurf_integration_output.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PYTHONPATH</key>
        <string>$(pwd)</string>
    </dict>
</dict>
</plist>
EOL

# Install launchd service
echo "Installing launchd service..."
cp com.windsurf.integration.plist ~/Library/LaunchAgents/
launchctl unload ~/Library/LaunchAgents/com.windsurf.integration.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.windsurf.integration.plist

# Set file permissions
echo "Setting file permissions..."
chmod +x setup_automation.sh

echo "Setup complete! Please edit .env file with your Windsurf API key and specific configurations."
echo "To start the service, run: launchctl start com.windsurf.integration"
