import platform
import os

def get_platform():
    return platform.system()

def display_details():
    print(f"Machine: {platform.machine()}")
    print(f"Release: {platform.release()}")
    print(f"CWD:     {os.getcwd()}")
