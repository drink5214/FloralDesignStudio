import requests
import json
import os
from typing import Dict, List, Optional

class WindsurfAPI:
    def __init__(self, api_key: str = None):
        self.api_key = api_key or os.environ.get('WINDSURF_API_KEY')
        self.base_url = os.environ.get('WINDSURF_API_URL', 'https://api.windsurf.ai/v1')
        
    def analyze_code(self, file_path: str, content: str) -> Dict:
        """
        Send code to Windsurf AI for analysis
        """
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'file_path': file_path,
            'content': content,
            'analysis_type': 'full'
        }
        
        response = requests.post(
            f'{self.base_url}/analyze',
            headers=headers,
            json=payload
        )
        response.raise_for_status()
        return response.json()
    
    def fix_issues(self, file_path: str, issues: List[Dict]) -> Dict:
        """
        Request fixes for identified issues
        """
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'file_path': file_path,
            'issues': issues,
            'auto_fix': True
        }
        
        response = requests.post(
            f'{self.base_url}/fix',
            headers=headers,
            json=payload
        )
        response.raise_for_status()
        return response.json()
    
    def analyze_build_error(self, error_log: str) -> Dict:
        """
        Analyze build errors and get suggested fixes
        """
        headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }
        
        payload = {
            'error_log': error_log,
            'project_type': 'ios',
            'suggest_fixes': True
        }
        
        response = requests.post(
            f'{self.base_url}/analyze/build-error',
            headers=headers,
            json=payload
        )
        response.raise_for_status()
        return response.json()
