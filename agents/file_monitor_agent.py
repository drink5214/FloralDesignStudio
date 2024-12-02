import asyncio
import logging
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FileMonitorAgent(FileSystemEventHandler):
    def __init__(self, project_path):
        super().__init__()
        self.project_path = project_path
        self.logger = logging.getLogger('WindsurfIntegration')
        self.observer = Observer()
        self.on_file_changed = None
        self._last_events = {}

    async def start(self):
        self.observer.schedule(self, self.project_path, recursive=True)
        self.observer.start()
        self.logger.info(f'Started monitoring: {self.project_path}')

    async def stop(self):
        self.observer.stop()
        self.observer.join()
        self.logger.info('Stopped monitoring')

    def on_modified(self, event):
        if event.is_directory:
            return

        file_path = event.src_path
        if self._should_process_file(file_path):
            asyncio.create_task(self._handle_modification(file_path))

    def _should_process_file(self, file_path: str) -> bool:
        valid_extensions = ['.swift', '.h', '.m', '.cpp', '.mm']
        return any(file_path.endswith(ext) for ext in valid_extensions)

    async def _handle_modification(self, file_path: str):
        current_time = asyncio.get_event_loop().time()
        last_time = self._last_events.get(file_path, 0)

        if current_time - last_time > 1.0:  # 1 second debounce
            self._last_events[file_path] = current_time
            if self.on_file_changed:
                await self.on_file_changed(file_path)