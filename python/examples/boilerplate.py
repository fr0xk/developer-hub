#!/usr/bin/env python3
"""
Suckless Python Boilerplate
Minimal dependencies, fast startup, clear structure.
"""
import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description="A pragmatic tool.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable debug logs")
    parser.add_argument("input", nargs="?", default="-", help="Input file (default: stdin)")
    return parser.parse_args()

def main():
    args = parse_args()
    
    # Logic goes here
    if args.input == "-":
        lines = sys.stdin.readlines()
    else:
        with open(args.input, "r") as f:
            lines = f.readlines()

    for line in lines:
        sys.stdout.write(line.upper())

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(130)
    except Exception as e:
        print(f"fatal: {e}", file=sys.stderr)
        sys.exit(1)
