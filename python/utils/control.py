#!/usr/bin/env python3
import os
import sys
import subprocess
import json

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True).decode().strip()
    except:
        return None

def main_menu():
    while True:
        os.system('clear')
        print("=== SUCKLESS TERMUX CONTROLLER ===")
        print("1. [Hardware] Toggle Flashlight")
        print("2. [Hardware] Get Battery Status")
        print("3. [Hardware] Set Brightness (0-255)")
        print("4. [Apps] List User Apps (Fast)")
        print("5. [Apps] Force Stop an App")
        print("6. [Memory] Free up RAM (Cache Purge)")
        print("7. [System] Get Device Info")
        print("q. Exit")
        
        choice = input("> ")
        
        if choice == '1':
            status = run("termux-torch")
            state = "on" if "off" in run("termux-torch") else "off" 
            run(f"termux-torch {state}")
        
        elif choice == '2':
            data = json.loads(run("termux-battery-status"))
            print(f"""
Level: {data['percentage']}% | Status: {data['status']} | Temp: {data['temperature']}°C""")
            input("Press Enter...")
            
        elif choice == '3':
            val = input("Brightness (0-255): ")
            run(f"termux-brightness {val}")
            
        elif choice == '4':
            print("""
""" + run("cmd package list packages -3 | cut -d: -f2"))
            input("Press Enter...")
            
        elif choice == '5':
            pkg = input("Enter package name: ")
            run(f"cmd activity force-stop {pkg}")
            print(f"Killed {pkg}")
            input("Press Enter...")
            
        elif choice == '6':
            print("[*] Purging user-space caches...")
            run("rm -rf ~/.cache/*")
            
            run("cmd activity trim-memory com.termux HIDDEN") 
            print("[+] RAM pressure reduced.")
            input("Press Enter...")
            
        elif choice == '7':
            print(f"""
Model: {run('getprop ro.product.model')}""")
            print(f"Android: {run('getprop ro.build.version.release')}")
            print(f"Uptime: {run('uptime -p')}")
            input("Press Enter...")
            
        elif choice == 'q':
            break

if __name__ == "__main__":
    
    if not run("command -v termux-battery-status"):
        print("[!] termux-api not found. Installing...")
        os.system("pkg install -y termux-api")
    
    main_menu()
