import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FileWatcherAgent(FileSystemEventHandler):
    def __init__(self, shared_state):
        self.shared_state = shared_state
        self.observer = Observer()

    def start(self, path):
        self.observer.schedule(self, path, recursive=True)
        self.observer.start()
        print(f'FileWatcherAgent: Started monitoring {path}')

    def on_modified(self, event):
        if not event.is_directory:
            print(f'FileWatcherAgent: Change detected in {event.src_path}')
            self.shared_state.queue_for_analysis(event.src_path)