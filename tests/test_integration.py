import unittest
import os
from unittest.mock import Mock, patch
from agents.file_monitor_agent import FileMonitorAgent
from agents.build_agent import BuildAgent
from agents.windsurf_client import WindsurfClient
from agents.error_handler import ErrorHandler
from agents.orchestrator import Orchestrator

class TestIntegration(unittest.TestCase):
    def setUp(self):
        """Set up test environment"""
        self.test_project_path = "/tmp/test_project"
        os.makedirs(self.test_project_path, exist_ok=True)
        
        # Mock agents
        self.file_monitor = Mock(spec=FileMonitorAgent)
        self.build_agent = Mock(spec=BuildAgent)
        self.windsurf_client = Mock(spec=WindsurfClient)
        self.error_handler = Mock(spec=ErrorHandler)
        
        # Create orchestrator with mock agents
        self.orchestrator = Orchestrator(
            self.file_monitor,
            self.build_agent,
            self.windsurf_client,
            self.error_handler
        )
        
    def test_file_change_workflow(self):
        """Test the complete workflow when a file changes"""
        # Mock file change
        test_file = os.path.join(self.test_project_path, "test.swift")
        
        # Simulate file change detection
        self.file_monitor.on_file_changed.return_value = test_file
        
        # Mock Windsurf response
        self.windsurf_client.analyze_code.return_value = {
            "has_errors": False,
            "corrections": []
        }
        
        # Mock successful build
        self.build_agent.build.return_value = (True, None)
        
        # Trigger workflow
        self.orchestrator.handle_file_change(test_file)
        
        # Verify workflow
        self.windsurf_client.analyze_code.assert_called_once()
        self.build_agent.build.assert_called_once()
        self.error_handler.handle_errors.assert_not_called()
        
    def tearDown(self):
        """Clean up test environment"""
        import shutil
        shutil.rmtree(self.test_project_path)

if __name__ == '__main__':
    unittest.main()