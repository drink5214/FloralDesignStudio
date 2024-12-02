import os
import time
from typing import Dict, List, Optional
from .build_agent import BuildAgent
from .windsurf_client import WindsurfClient

class ErrorHandler:
    def __init__(self, project_path: str):
        self.project_path = os.path.abspath(project_path)
        self.build_agent = BuildAgent(project_path)
        self.windsurf_client = WindsurfClient()
        self.max_retry_attempts = 3
        self.retry_delay = 5  # seconds
        
    def handle_file_error(self, file_path: str) -> bool:
        """Handle errors in a specific file"""
        try:
            # Get Windsurf review
            review_result = self.windsurf_client.review_code(file_path)
            
            if 'error' in review_result:
                print(f"Review failed: {review_result['error']}")
                return False
                
            if review_result.get('issues', []):
                # Attempt to fix issues
                fix_result = self.windsurf_client.fix_code(file_path, review_result['issues'])
                return 'error' not in fix_result
            
            return True
            
        except Exception as e:
            print(f"Error handling file error: {str(e)}")
            return False
    
    def handle_build_error(self) -> bool:
        """Handle build errors with retry logic"""
        attempts = 0
        while attempts < self.max_retry_attempts:
            try:
                # Get build errors
                build_errors = self.build_agent.get_build_errors()
                
                if not build_errors:
                    return True
                
                # Analyze errors with Windsurf
                analysis = self.windsurf_client.analyze_build_errors(build_errors)
                
                if 'error' in analysis:
                    print(f"Analysis failed: {analysis['error']}")
                    return False
                
                # Handle each file that needs fixing
                files_to_fix = analysis.get('files_to_fix', [])
                for file_info in files_to_fix:
                    file_path = file_info['file_path']
                    if not self.handle_file_error(file_path):
                        print(f"Failed to fix {file_path}")
                        continue
                
                # Try building again
                if self.build_agent.clean_build() and self.build_agent.start_build():
                    return True
                
                attempts += 1
                if attempts < self.max_retry_attempts:
                    print(f"Retrying build... Attempt {attempts + 1}/{self.max_retry_attempts}")
                    time.sleep(self.retry_delay)
                    
            except Exception as e:
                print(f"Error in build error handling: {str(e)}")
                attempts += 1
        
        return False
    
    def run_error_correction_loop(self) -> bool:
        """Run the complete error correction loop"""
        try:
            # Start a build
            if not self.build_agent.start_build():
                # Handle build errors if build fails
                return self.handle_build_error()
            
            return True
            
        except Exception as e:
            print(f"Error in correction loop: {str(e)}")
            return False