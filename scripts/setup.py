import os
import subprocess
import sys
import shutil
from pathlib import Path

class SetupAutomation:
    def __init__(self):
        self.project_root = Path.cwd()
        self.venv_path = self.project_root / 'venv'
        self.logs_path = self.project_root / 'logs'
        self.build_path = self.project_root / 'build_output'

    def setup_directories(self):
        print('Creating necessary directories...')
        for path in [self.logs_path, self.build_path]:
            path.mkdir(parents=True, exist_ok=True)

    def setup_virtual_environment(self):
        print('Setting up Python virtual environment...')
        subprocess.run([sys.executable, '-m', 'venv', str(self.venv_path)], check=True)
        
        # Install dependencies
        pip_path = self.venv_path / 'bin' / 'pip'
        subprocess.run([str(pip_path), 'install', '-r', 'requirements.txt'], check=True)

    def setup_launchd(self):
        print('Setting up launchd service...')
        plist_path = Path.home() / 'Library/LaunchAgents/com.windsurf.integration.plist'
        shutil.copy('config/com.windsurf.integration.plist', str(plist_path))
        
        # Load the service
        subprocess.run(['launchctl', 'unload', str(plist_path)], check=False)
        subprocess.run(['launchctl', 'load', str(plist_path)], check=True)

    def configure_environment(self):
        print('Setting up environment configuration...')
        if not Path('.env').exists():
            shutil.copy('.env.example', '.env')
            print('Please edit .env file with your specific configurations')

    def run_tests(self):
        print('Running tests...')
        pytest_path = self.venv_path / 'bin' / 'pytest'
        subprocess.run([str(pytest_path), 'tests/'], check=True)

    def setup_all(self):
        try:
            self.setup_directories()
            self.setup_virtual_environment()
            self.configure_environment()
            self.setup_launchd()
            self.run_tests()
            print('\nSetup completed successfully!')
        except Exception as e:
            print(f'\nError during setup: {str(e)}')
            sys.exit(1)

if __name__ == '__main__':
    setup = SetupAutomation()
    setup.setup_all()