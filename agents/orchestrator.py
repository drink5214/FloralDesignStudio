import asyncio
import logging
from typing import Optional

class Orchestrator:
    def __init__(self, file_monitor, build_agent, windsurf_client, error_handler):
        self.file_monitor = file_monitor
        self.build_agent = build_agent
        self.windsurf_client = windsurf_client
        self.error_handler = error_handler
        self.logger = logging.getLogger('WindsurfIntegration')

    async def handle_file_change(self, file_path: str):
        """Handle a file change event"""
        self.logger.info(f'Processing file change: {file_path}')

        # Analyze with Windsurf
        analysis = await self.windsurf_client.analyze_code(file_path)
        if analysis.get('has_errors'):
            # Let Windsurf fix the errors
            await self.error_handler.handle_errors(file_path, analysis['corrections'])

        # Trigger build
        success, errors = await self.build_agent.build()
        if not success:
            # Send build errors to Windsurf
            await self.error_handler.handle_build_errors(errors)

    async def start(self):
        """Start the orchestration process"""
        self.logger.info('Starting Windsurf integration orchestrator')
        
        # Start file monitoring
        self.file_monitor.on_file_changed = self.handle_file_change
        await self.file_monitor.start()

        try:
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            await self.stop()

    async def stop(self):
        """Stop the orchestration process"""
        self.logger.info('Stopping orchestrator')
        await self.file_monitor.stop()