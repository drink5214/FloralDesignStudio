import time
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FileChangeHandler(FileSystemEventHandler):
    def __init__(self, project_path):
        self.project_path = project_path
        self.last_modified = {}
        
    def on_modified(self, event):
        if event.is_directory:
            return
            
        # Get absolute path of modified file
        file_path = os.path.abspath(event.src_path)
        
        # Check if file is part of the Xcode project
        if not self._is_project_file(file_path):
            return
            
        # Avoid duplicate events by checking last modified time
        current_time = time.time()
        if file_path in self.last_modified:
            if current_time - self.last_modified[file_path] < 1:  # 1 second debounce
                return
                
        self.last_modified[file_path] = current_time
        self._handle_file_change(file_path)
        
    def _is_project_file(self, file_path):
        """Check if file is part of the Xcode project"""
        # Skip hidden files and build artifacts
        if '/.' in file_path or '/build/' in file_path:
            return False
            
        # Only monitor source code and project files
        valid_extensions = ['.swift', '.h', '.m', '.cpp', '.c', '.mm', '.pbxproj']
        return any(file_path.endswith(ext) for ext in valid_extensions)
        
    def _handle_file_change(self, file_path):
        """Handle detected file changes"""
        print(f"File changed: {file_path}")
        # This will be expanded to integrate with Windsurf and Build agents

class FileMonitorAgent:
    def __init__(self, project_path):
        self.project_path = os.path.abspath(project_path)
        self.event_handler = FileChangeHandler(self.project_path)
        self.observer = Observer()
        
    def start(self):
        """Start monitoring for file changes"""
        self.observer.schedule(self.event_handler, self.project_path, recursive=True)
        self.observer.start()
        print(f"Started monitoring: {self.project_path}")
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()
            
    def stop(self):
        """Stop monitoring for file changes"""
        self.observer.stop()
        self.observer.join()
        print("Stopped monitoring")