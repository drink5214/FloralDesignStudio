import subprocess
import os
import json
from typing import Dict, List, Optional

class BuildAgent:
    def __init__(self, project_path: str):
        self.project_path = os.path.abspath(project_path)
        self.current_build = None
        self.build_logs = []
        
    def start_build(self) -> bool:
        """Start a new Xcode build"""
        try:
            # Prepare build command
            build_cmd = [
                'xcodebuild',
                '-project', f"{self.project_path}/FloralDesignStudio.xcodeproj",
                '-scheme', 'FloralDesignStudio',
                '-destination', 'platform=iOS Simulator,name=iPhone 14 Pro,OS=latest',
                'build'
            ]
            
            # Start build process
            process = subprocess.Popen(
                build_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            self.current_build = process
            stdout, stderr = process.communicate()
            
            # Store build log
            build_log = {
                'stdout': stdout,
                'stderr': stderr,
                'return_code': process.returncode
            }
            self.build_logs.append(build_log)
            
            return process.returncode == 0
            
        except Exception as e:
            print(f"Build error: {str(e)}")
            return False
    
    def get_build_errors(self) -> List[Dict]:
        """Extract build errors from latest build log"""
        if not self.build_logs:
            return []
            
        latest_log = self.build_logs[-1]
        errors = []
        
        # Parse stderr for error messages
        if latest_log['stderr']:
            for line in latest_log['stderr'].split('\n'):
                if 'error:' in line.lower():
                    errors.append({
                        'type': 'error',
                        'message': line.strip(),
                        'raw': line
                    })
        
        # Parse stdout for error messages
        if latest_log['stdout']:
            for line in latest_log['stdout'].split('\n'):
                if 'error:' in line.lower():
                    errors.append({
                        'type': 'error',
                        'message': line.strip(),
                        'raw': line
                    })
        
        return errors
    
    def cancel_build(self) -> bool:
        """Cancel the current build if one is running"""
        if self.current_build and self.current_build.poll() is None:
            self.current_build.terminate()
            return True
        return False
    
    def clean_build(self) -> bool:
        """Clean the build directory"""
        try:
            clean_cmd = [
                'xcodebuild',
                '-project', f"{self.project_path}/FloralDesignStudio.xcodeproj",
                'clean'
            ]
            
            process = subprocess.run(clean_cmd, capture_output=True, text=True)
            return process.returncode == 0
            
        except Exception as e:
            print(f"Clean error: {str(e)}")
            return False