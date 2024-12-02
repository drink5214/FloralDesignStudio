import asyncio
from config.config_loader import config
from agents.orchestrator import Orchestrator
from agents.file_monitor_agent import FileMonitorAgent
from agents.build_agent import BuildAgent
from agents.windsurf_client import WindsurfClient
from agents.error_handler import ErrorHandler

async def main():
    # Initialize agents
    file_monitor = FileMonitorAgent(config.build_config['project_path'])
    build_agent = BuildAgent(config.build_config)
    windsurf_client = WindsurfClient(config.windsurf_config)
    error_handler = ErrorHandler()

    # Create orchestrator
    orchestrator = Orchestrator(
        file_monitor,
        build_agent,
        windsurf_client,
        error_handler
    )

    # Start the system
    await orchestrator.start()

if __name__ == '__main__':
    asyncio.run(main())