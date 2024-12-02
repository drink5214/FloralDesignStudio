import asyncio
import logging
from typing import Dict, Any

class Orchestrator:
    """Main orchestrator for managing all the AI agents and their interactions"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger('WindsurfIntegration')
        self.file_monitor = None
        self.build_agent = None
        self.windsurf_client = None
        self.error_handler = None
        self.is_running = False

    async def start(self):
        """Initialize and start all agents"""
        self.logger.info("Starting Windsurf-Xcode integration orchestrator")
        
        try:
            # Initialize agents
            await self._init_agents()
            
            # Start file monitoring
            await self.file_monitor.start()
            self.is_running = True
            
            # Main loop
            while self.is_running:
                await asyncio.sleep(1)
                
        except Exception as e:
            self.logger.error(f"Error in orchestrator: {str(e)}")
            await self.stop()
            raise

    async def stop(self):
        """Stop all agents and cleanup"""
        self.logger.info("Stopping orchestrator")
        self.is_running = False
        
        if self.file_monitor:
            await self.file_monitor.stop()

    async def _init_agents(self):
        """Initialize all required agents"""
        # Import agents here to avoid circular imports
        from .file_monitor_agent import FileMonitorAgent
        from .build_agent import BuildAgent
        from .windsurf_client import WindsurfClient
        from .error_handler import ErrorHandler
        
        self.file_monitor = FileMonitorAgent(self.config)
        self.build_agent = BuildAgent(self.config)
        self.windsurf_client = WindsurfClient(self.config)
        self.error_handler = ErrorHandler(self.config)

        # Set up event handlers
        self.file_monitor.on_file_changed = self._handle_file_change
        self.build_agent.on_build_failed = self._handle_build_failure

    async def _handle_file_change(self, file_path: str):
        """Handle file change events"""
        self.logger.info(f"File changed: {file_path}")
        
        try:
            # Send to Windsurf for analysis
            analysis = await self.windsurf_client.analyze_code(file_path)
            
            if analysis.get('has_errors'):
                # Apply corrections from Windsurf
                await self.error_handler.apply_corrections(file_path, analysis['corrections'])
            
            # Trigger build
            await self.build_agent.start_build()
            
        except Exception as e:
            self.logger.error(f"Error handling file change: {str(e)}")

    async def _handle_build_failure(self, error_output: str):
        """Handle build failures"""
        self.logger.info("Handling build failure")
        
        try:
            # Send build errors to Windsurf
            analysis = await self.windsurf_client.analyze_build_errors(error_output)
            
            if analysis.get('corrections'):
                # Apply corrections
                for correction in analysis['corrections']:
                    await self.error_handler.apply_corrections(
                        correction['file'],
                        correction['changes']
                    )
                
                # Retry build
                await self.build_agent.start_build()
                
        except Exception as e:
            self.logger.error(f"Error handling build failure: {str(e)}")
