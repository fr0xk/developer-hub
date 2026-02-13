#!/usr/bin/env python3
import sys
import argparse
from utils import system_info

class CoreTool:
    def __init__(self, config):
        self.config = config
        self.os_type = system_info.get_platform()

    def run(self):
        print(f"[*] Starting core_py on {self.os_type}...")
        if self.config.verbose:
            system_info.display_details()
        
        print(f"[+] Task '{self.config.action}' completed.")

def main():
    parser = argparse.ArgumentParser(description="Core Python Pragmatic Template")
    parser.add_argument("action", help="Action to perform")
    parser.add_argument("-v", "--verbose", action="store_true", help="Detailed output")
    
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()
    tool = CoreTool(args)
    tool.run()

if __name__ == "__main__":
    main()
