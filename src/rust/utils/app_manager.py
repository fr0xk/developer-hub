#!/usr/bin/env python3
import os
import sys
import subprocess

BACKUP_DIR = os.path.expanduser("~/storage/shared/AppBackup")

def get_user_packages():
    print("[*] Fetching user-installed packages...")
    cmd = "cmd package list packages -3"
    output = subprocess.check_output(cmd, shell=True).decode()
    packages = [line.split(":")[1].strip() for line in output.splitlines() if line.strip()]
    return packages

def backup():
    packages = get_user_packages()
    total = len(packages)
    print(f"[+] Found {total} apps. Starting backup...")
    
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)

    for i, pkg in enumerate(packages, 1):
        print(f"[{i}/{total}] Backing up: {pkg}...")
        pkg_dir = os.path.join(BACKUP_DIR, pkg)
        os.makedirs(pkg_dir, exist_ok=True)
        
        
        path_cmd = f"cmd package path {pkg}"
        paths = subprocess.check_output(path_cmd, shell=True).decode().splitlines()
        
        for p_line in paths:
            apk_src = p_line.split(":")[1].strip()
            apk_name = os.path.basename(apk_src)
            apk_dest = os.path.join(pkg_dir, apk_name)
            
            try:
                subprocess.run(f"cat {apk_src} > {apk_dest}", shell=True, check=True)
            except Exception as e:
                print(f"    [!] Failed to copy {apk_name}: {e}")

    print(f"\n[!] Backup complete. Files stored in: {BACKUP_DIR}")

def restore():
    print("[*] Starting restoration process...")
    if not os.path.exists(BACKUP_DIR):
        print("Error: Backup directory not found.")
        return

    packages = sorted([d for d in os.listdir(BACKUP_DIR) if os.path.isdir(os.path.join(BACKUP_DIR, d))])
    
    print("This will trigger the Android package installer for each app.")
    print("You will need to manually click 'Install' for each prompt.\n")

    for pkg in packages:
        pkg_path = os.path.join(BACKUP_DIR, pkg)
        apks = [f for f in os.listdir(pkg_path) if f.endswith(".apk")]
        if not apks: continue
        
        base_apk = "base.apk" if "base.apk" in apks else apks[0]
        full_path = os.path.join(pkg_path, base_apk)
        
        print(f"[+] Opening installer for: {pkg}")
        subprocess.run(f"termux-open {full_path}", shell=True)
        
        input("Press Enter once you have finished installing this app to proceed to the next...")

    print("\n[!] Restoration cycle finished.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python app_manager.py [backup|restore]")
        sys.exit(1)
    
    action = sys.argv[1].lower()
    if action == "backup": backup()
    elif action == "restore": restore()
    else: print("Invalid action.")
