#!/usr/bin/env python3
import os
import json
import urllib.request
import re


REPO = "BlinkDL/rwkv-7-gguf"
MODEL_PATTERN = r"RWKV-7-World-1.5B-.*Q4_K_M\.gguf"
SAVE_DIR = os.path.expanduser("~/.models")

def get_latest_model_url():
    print(f"[*] Fetching file list from {REPO}...")
    api_url = f"https://huggingface.co/api/models/{REPO}/tree/main"
    
    try:
        with urllib.request.urlopen(api_url) as response:
            files = json.loads(response.read().decode())
            
        
        matches = [f['path'] for f in files if re.search(MODEL_PATTERN, f['path'])]
        
        if not matches:
            print("[!] No matching models found in the repository.")
            return None
            
        
        latest_file = sorted(matches)[-1]
        download_url = f"https://huggingface.co/{REPO}/resolve/main/{latest_file}"
        return download_url, latest_file

    except Exception as e:
        print(f"[!] Error fetching metadata: {e}")
        return None

def download():
    result = get_latest_model_url()
    if not result:
        return
        
    url, filename = result
    dest = os.path.join(SAVE_DIR, filename)
    
    if os.path.exists(dest):
        print(f"[!] {filename} is already downloaded.")
        return

    os.makedirs(SAVE_DIR, exist_ok=True)
    print(f"[+] Downloading: {filename}")
    print(f"[+] URL: {url}")
    
    try:
        urllib.request.urlretrieve(url, dest, 
            reporthook=lambda block, size, total: 
                print(f"\r[+] Progress: {(block*size/total)*100:.1f}%", end="") if total > 0 else None)
        print(f"\n[!] Download complete: {dest}")
    except Exception as e:
        print(f"\n[!] Download failed: {e}")

if __name__ == "__main__":
    download()
