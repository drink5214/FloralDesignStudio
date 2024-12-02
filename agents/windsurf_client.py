import requests
import json
import os
from typing import Dict, List, Optional

class WindsurfClient:
    def __init__(self):
        self.api_key = os.environ.get('WINDSURF_API_KEY')
        self.api_url = os.environ.get('WINDSURF_API_URL', 'https://api.windsurf.ai/v1')
        if not self.api_key:
            raise ValueError('WINDSURF_API_KEY environment variable is required')
    
    def review_code(self, file_path: str) -> Dict:
        """Send code file to Windsurf for review"""
        try:
            with open(file_path, 'r') as f:
                code_content = f.read()
            
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'file_path': file_path,
                'content': code_content,
                'review_type': 'full'
            }
            
            response = requests.post(
                f'{self.api_url}/review',
                headers=headers,
                json=payload
            )
            response.raise_for_status()
            return response.json()
            
        except Exception as e:
            print(f"Code review error: {str(e)}")
            return {'error': str(e)}
    
    def fix_code(self, file_path: str, issues: List[Dict]) -> Dict:
        """Request code fixes from Windsurf"""
        try:
            with open(file_path, 'r') as f:
                code_content = f.read()
            
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'file_path': file_path,
                'content': code_content,
                'issues': issues
            }
            
            response = requests.post(
                f'{self.api_url}/fix',
                headers=headers,
                json=payload
            )
            response.raise_for_status()
            
            # Apply fixes if provided
            result = response.json()
            if 'fixed_content' in result:
                with open(file_path, 'w') as f:
                    f.write(result['fixed_content'])
            
            return result
            
        except Exception as e:
            print(f"Code fix error: {str(e)}")
            return {'error': str(e)}
    
    def analyze_build_errors(self, build_errors: List[Dict]) -> Dict:
        """Send build errors to Windsurf for analysis"""
        try:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'errors': build_errors,
                'project_type': 'ios'
            }
            
            response = requests.post(
                f'{self.api_url}/analyze/build',
                headers=headers,
                json=payload
            )
            response.raise_for_status()
            return response.json()
            
        except Exception as e:
            print(f"Build error analysis error: {str(e)}")
            return {'error': str(e)}