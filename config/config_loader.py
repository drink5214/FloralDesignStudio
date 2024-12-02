import os
from dotenv import load_dotenv
import logging

class ConfigLoader:
    def __init__(self):
        self.load_environment()
        self.setup_logging()
        
    def load_environment(self):
        """Load environment variables from .env file"""
        env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
        load_dotenv(env_path)
        
        # Required configurations
        self.validate_required_configs()
        
        # Build configurations
        self.build_config = {
            'project_path': os.getenv('PROJECT_PATH'),
            'project_name': os.getenv('XCODE_PROJECT_NAME'),
            'scheme_name': os.getenv('XCODE_SCHEME_NAME'),
            'build_config': os.getenv('BUILD_CONFIGURATION', 'Debug'),
            'output_path': os.getenv('BUILD_OUTPUT_PATH')
        }
        
        # Windsurf configurations
        self.windsurf_config = {
            'api_key': os.getenv('WINDSURF_API_KEY'),
            'api_url': os.getenv('WINDSURF_API_URL')
        }
        
        # Agent configurations
        self.agent_config = {
            'debounce_time': float(os.getenv('FILE_MONITOR_DEBOUNCE_TIME', '1.0')),
            'build_retry_limit': int(os.getenv('BUILD_RETRY_LIMIT', '3')),
            'error_correction_timeout': int(os.getenv('ERROR_CORRECTION_TIMEOUT', '300'))
        }
        
    def validate_required_configs(self):
        """Validate that all required environment variables are set"""
        required_vars = [
            'WINDSURF_API_KEY',
            'WINDSURF_API_URL',
            'PROJECT_PATH',
            'XCODE_PROJECT_NAME',
            'XCODE_SCHEME_NAME'
        ]
        
        missing_vars = [var for var in required_vars if not os.getenv(var)]
        if missing_vars:
            raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")
            
    def setup_logging(self):
        """Setup logging configuration"""
        log_level = os.getenv('LOG_LEVEL', 'INFO')
        log_file = os.getenv('LOG_FILE_PATH', 'windsurf_integration.log')
        
        logging.basicConfig(
            level=getattr(logging, log_level.upper()),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler()
            ]
        )
        
    @property
    def logger(self):
        return logging.getLogger('WindsurfIntegration')
        
config = ConfigLoader()