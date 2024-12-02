import os
import sys
import json
from agents.file_watcher_agent import FileWatcherAgent
from agents.windsurf_agent import WindsurfAgent
from agents.build_agent import BuildAgent

def load_config():
    with open('config.json') as f:
        return json.load(f)

def main():
    try:
        config = load_config()
        print("Starting automation system...")
        
        # Initialize agents
        watcher = FileWatcherAgent(config['watch_paths'])
        windsurf = WindsurfAgent(config['windsurf'])
        builder = BuildAgent(config['xcode'])
        
        # Start monitoring
        watcher.start()
        
        print("Automation system running...")
        while True:
            pass
            
    except KeyboardInterrupt:
        print("Shutting down automation system...")
        sys.exit(0)

if __name__ == "__main__":
    main()