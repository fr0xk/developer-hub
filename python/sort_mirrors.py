import os
import re
import requests
import time
import subprocess
from concurrent.futures import ThreadPoolExecutor

# Paths
PREFIX = "/data/data/com.termux/files/usr"
MIRROR_BASE_DIR = f"{PREFIX}/etc/termux/mirrors"
SOURCES_LIST = f"{PREFIX}/etc/apt/sources.list"
SOURCES_LIST_D = f"{PREFIX}/etc/apt/sources.list.d"
CHOSEN_MIRRORS = f"{PREFIX}/etc/termux/chosen_mirrors"

def parse_mirror_file(file_path):
    try:
        with open(file_path, 'r') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None
    
    mirror = {
        'path': file_path,
        'name': os.path.basename(file_path),
        'MAIN': None,
        'ROOT': None,
        'X11': None,
        'WEIGHT': 1
    }
    
    main_match = re.search(r'^MAIN="(.+)"', content, re.M)
    if main_match:
        mirror['MAIN'] = main_match.group(1)
        
    root_match = re.search(r'^ROOT="(.+)"', content, re.M)
    if root_match:
        mirror['ROOT'] = root_match.group(1)
        
    x11_match = re.search(r'^X11="(.+)"', content, re.M)
    if x11_match:
        mirror['X11'] = x11_match.group(1)
        
    weight_match = re.search(r'^WEIGHT=(\d+)', content, re.M)
    if weight_match:
        mirror['WEIGHT'] = int(weight_match.group(1))
        
    return mirror

def get_all_mirrors():
    mirrors = []
    # Add default mirror
    default_mirror = f"{MIRROR_BASE_DIR}/default"
    if os.path.exists(default_mirror):
        m = parse_mirror_file(default_mirror)
        if m: mirrors.append(m)
        
    # Walk through regions
    for root, dirs, files in os.walk(MIRROR_BASE_DIR):
        for name in files:
            if name == "default" or name.endswith(".dpkg-old") or name.endswith(".dpkg-new") or name.endswith("~"):
                continue
            path = os.path.join(root, name)
            m = parse_mirror_file(path)
            if m: mirrors.append(m)
    
    return [m for m in mirrors if m and m.get('MAIN')]

def test_mirror_speed(mirror):
    url = f"{mirror['MAIN'].rstrip('/')}/dists/stable/Release"
    try:
        start_time = time.time()
        # HEAD request to check availability and measure latency
        response = requests.head(url, timeout=5, allow_redirects=True)
        if response.status_code == 200:
            latency = (time.time() - start_time) * 1000
            mirror['latency'] = latency
            return mirror
    except Exception:
        pass
    
    mirror['latency'] = float('inf')
    return mirror

def update_sources_list(mirror):
    # Update main sources.list
    with open(SOURCES_LIST, 'w') as f:
        f.write(f"deb {mirror['MAIN']} stable main\n")
    print(f"[*] Updated {SOURCES_LIST}")
    
    # Update root.list if exists
    root_list = os.path.join(SOURCES_LIST_D, "root.list")
    if os.path.exists(root_list) and mirror['ROOT']:
        with open(root_list, 'w') as f:
            f.write(f"deb {mirror['ROOT']} root stable\n")
        print(f"[*] Updated {root_list}")
        
    # Update x11.list if exists
    x11_list = os.path.join(SOURCES_LIST_D, "x11.list")
    if os.path.exists(x11_list) and mirror['X11']:
        with open(x11_list, 'w') as f:
            f.write(f"deb {mirror['X11']} x11 main\n")
        print(f"[*] Updated {x11_list}")

def set_permanent_mirror(mirror_path):
    if os.path.lexists(CHOSEN_MIRRORS):
        os.unlink(CHOSEN_MIRRORS)
    os.symlink(mirror_path, CHOSEN_MIRRORS)
    print(f"[*] Linked {CHOSEN_MIRRORS} to {mirror_path}")

def main():
    print("[*] Collecting mirrors...")
    mirrors = get_all_mirrors()
    print(f"[*] Found {len(mirrors)} mirrors.")
    
    print("[*] Testing mirrors (this may take a minute)...")
    with ThreadPoolExecutor(max_workers=10) as executor:
        results = list(executor.map(test_mirror_speed, mirrors))
    
    # Filter out failed mirrors and sort by latency
    valid_results = [m for m in results if m['latency'] != float('inf')]
    valid_results.sort(key=lambda x: x['latency'])
    
    if not valid_results:
        print("[!] No reachable mirrors found!")
        return
    
    print("\nTop 5 fastest mirrors:")
    for i, m in enumerate(valid_results[:5]):
        print(f"{i+1}. {m['name']} ({m['latency']:.2f} ms) - {m['MAIN']}")
        
    fastest = valid_results[0]
    print(f"\n[*] Selected fastest mirror: {fastest['name']} ({fastest['latency']:.2f} ms)")
    
    update_sources_list(fastest)
    set_permanent_mirror(fastest['path'])
    
    print("[*] Running 'pkg update' to apply changes...")
    try:
        subprocess.run(["pkg", "update"], check=True)
        print("\n[+] Done! The fastest mirror is now permanently configured.")
    except subprocess.CalledProcessError:
        print("\n[!] 'pkg update' failed, but configuration was updated.")

if __name__ == "__main__":
    main()
