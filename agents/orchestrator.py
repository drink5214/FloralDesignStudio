import os
import sys
import time
from typing import Optional
from file_monitor_agent import FileMonitorAgent
from build_agent import BuildAgent
from windsurf_client import WindsurfClient
from error_handler import ErrorHandler

class Orchestrator:
    def __init__(self, project_path: str):
        self.project_path = os.path.abspath(project_path)
        self.file_monitor = FileMonitorAgent(project_path)
        self.build_agent = BuildAgent(project_path)
        self.windsurf_client = WindsurfClient()
        self.error_handler = ErrorHandler(project_path)
        self.is_running = False
        
    def start(self):
        """Start the automation system"""
        try:
            self.is_running = True
            print(f"Starting Xcode-Windsurf automation for: {self.project_path}")
            
            # Set up file monitor callback
            self.file_monitor.event_handler.on_file_changed = self._handle_file_change
            
            # Start file monitoring
            self.file_monitor.start()
            
        except Exception as e:
            print(f"Orchestrator startup error: {str(e)}")
            self.stop()
    
    def stop(self):
        """Stop the automation system"""
        self.is_running = False
        self.file_monitor.stop()
        self.build_agent.cancel_build()
        print("Automation system stopped")
    
    def _handle_file_change(self, file_path: str):
        """Handle file change events"""
        try:
            print(f"\nFile changed: {file_path}")
            
            # Send to Windsurf for review
            review_result = self.windsurf_client.review_code(file_path)
            
            if 'error' in review_result:
                print(f"Windsurf review failed: {review_result['error']}")
                return
            
            if review_result.get('issues', []):
                print("Issues found - attempting fixes...")
                if not self.error_handler.handle_file_error(file_path):
                    print("Failed to fix all issues")
                    return
            
            # Start a new build
            print("Starting build...")
            if not self.build_agent.start_build():
                print("Build failed - starting error correction loop...")
                if self.error_handler.run_error_correction_loop():
                    print("Error correction successful")
                else:
                    print("Error correction failed")
            else:
                print("Build successful")
                
        except Exception as e:
            print(f"Error handling file change: {str(e)}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python orchestrator.py <project_path>")
        sys.exit(1)
        
    project_path = sys.argv[1]
    orchestrator = Orchestrator(project_path)
    
    try:
        orchestrator.start()
    except KeyboardInterrupt:
        print("\nShutting down...")
        orchestrator.stop()

if __name__ == '__main__':
    main()