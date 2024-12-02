import aiohttp
import logging
from typing import Dict, Any

class WindsurfClient:
    def __init__(self, config: Dict[str, str]):
        self.api_key = config['api_key']
        self.api_url = config['api_url']
        self.logger = logging.getLogger('WindsurfIntegration')

    async def analyze_code(self, file_path: str) -> Dict[str, Any]:
        """Send code to Windsurf for analysis"""
        self.logger.info(f'Analyzing file: {file_path}')

        async with aiohttp.ClientSession() as session:
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json'
            }

            with open(file_path, 'r') as f:
                code = f.read()

            data = {
                'code': code,
                'language': self._detect_language(file_path)
            }

            async with session.post(
                f'{self.api_url}/analyze',
                headers=headers,
                json=data
            ) as response:
                return await response.json()

    def _detect_language(self, file_path: str) -> str:
        """Detect programming language from file extension"""
        ext = file_path.split('.')[-1].lower()
        language_map = {
            'swift': 'swift',
            'h': 'objective-c',
            'm': 'objective-c',
            'mm': 'objective-c++',
            'cpp': 'c++',
            'c': 'c'
        }
        return language_map.get(ext, 'unknown')