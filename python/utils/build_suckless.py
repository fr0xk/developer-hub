#!/usr/bin/env python3
import os
import subprocess




TARGET_DIR = "target/debug/deps"
SRC = "src/main.rs"
OUT = "my_app"

def get_externs():
    externs = []
    if not os.path.exists(TARGET_DIR):
        return ""
    
    
    for file in os.listdir(TARGET_DIR):
        if file.endswith(".rlib"):
            
            
            parts = file[3:].split('-')
            if len(parts) > 1:
                name = parts[0]
                path = os.path.join(TARGET_DIR, file)
                externs.append(f"--extern {name}={path}")
    
    return " ".join(externs)

def build():
    flags = "-O -C debuginfo=0 -C target-cpu=native"
    links = get_externs()
    
    cmd = f"rustc {flags} {links} -L {TARGET_DIR} {SRC} -o {OUT}"
    
    print(f"""[*] Executing manual build:
{cmd}
""")
    try:
        subprocess.run(cmd, shell=True, check=True)
        print("[+] Build Successful!")
    except:
        print("[!] Build Failed. Ensure you have run 'cargo build' at least once to cache the crates.")

if __name__ == "__main__":
    build()
