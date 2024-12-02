import asyncio
import logging
from typing import Tuple, Optional
import subprocess

class BuildAgent:
    def __init__(self, config):
        self.config = config
        self.logger = logging.getLogger('WindsurfIntegration')

    async def build(self) -> Tuple[bool, Optional[str]]:
        """Build the Xcode project"""
        self.logger.info('Starting build process')

        cmd = [
            'xcodebuild',
            '-project', self.config['project_name'],
            '-scheme', self.config['scheme_name'],
            '-configuration', self.config['build_config'],
            'build'
        ]

        try:
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            stdout, stderr = await process.communicate()
            success = process.returncode == 0

            if not success:
                error_output = stderr.decode() if stderr else stdout.decode()
                self.logger.error(f'Build failed: {error_output}')
                return False, error_output

            self.logger.info('Build completed successfully')
            return True, None

        except Exception as e:
            self.logger.error(f'Build process error: {str(e)}')
            return False, str(e)