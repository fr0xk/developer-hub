#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

def run_cmd(cmd, check=True, capture=False, shell=False):
    print(f"[*] Running: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    res = subprocess.run(
        cmd,
        shell=shell,
        check=False,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        text=True
    )
    if check and res.returncode != 0:
        print(f"[!] Error executing: {cmd}")
        if res.stderr:
            print(res.stderr)
        sys.exit(res.returncode)
    return res

def is_installed_pkg(pkg_name):
    res = subprocess.run(["dpkg", "-s", pkg_name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return res.returncode == 0

def install_pacman():
    if not is_installed_pkg("pacman"):
        print("[*] pacman not found. Installing via pkg...")
        run_cmd(["pkg", "update", "-y"])
        run_cmd(["pkg", "install", "-y", "pacman"])
    else:
        print("[*] pacman is already installed.")

def setup_pacman():
    print("[*] Initializing pacman keys...")
    run_cmd(["pacman-key", "--init"])
    print("[*] Populating pacman keys...")
    run_cmd(["pacman-key", "--populate"])
    print("[*] Syncing pacman databases...")
    run_cmd(["pacman", "-Sy"])

def deploy_safe_pacman():
    bin_dir = Path.home() / ".local" / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    safe_pacman_path = bin_dir / "safe-pacman"
    
    print(f"[*] Deploying wrapper script to {safe_pacman_path}...")
    
    # We use dynamic termux prefix resolution for paths
    prefix = os.environ.get('PREFIX', '/data/data/com.termux/files/usr')
    python_path = f"{prefix}/bin/python"
    
    script_content = f"""#!{python_path}
import sys
import subprocess
import os

def run_cmd(cmd, shell=False, check=False, capture=True):
    res = subprocess.run(cmd, shell=shell, stdout=subprocess.PIPE if capture else None, stderr=subprocess.PIPE if capture else None, text=True)
    if check and res.returncode != 0:
        print(f"Command failed: {{cmd}}")
        if res.stderr:
            print(res.stderr)
        sys.exit(res.returncode)
    return res

def check_conflicts(packages):
    print(f"Checking for conflicts for packages: {{', '.join(packages)}}...")
    
    print("Downloading packages...")
    run_cmd(['pacman', '-Sw', '--noconfirm'] + packages, check=True, capture=False)
    
    print("Locating cached packages...")
    cache_dir = '{prefix}/var/cache/pacman/pkg'
    
    conflicts = []
    
    for pkg in packages:
        res = run_cmd(['pacman', '-Sp', pkg])
        urls = [l for l in res.stdout.splitlines() if l.startswith('http') or l.startswith('file://')]
        if not urls:
            continue
        
        filename = urls[-1].split('/')[-1]
        filepath = os.path.join(cache_dir, filename)
        
        if not os.path.exists(filepath):
            print(f"Warning: Cached file not found for {{pkg}}: {{filepath}}")
            continue
            
        print(f"Analyzing {{pkg}}...")
        res = run_cmd(['pacman', '-Qpl', filepath])
        files = []
        for line in res.stdout.splitlines():
            parts = line.split(maxsplit=1)
            if len(parts) == 2:
                files.append(parts[1])
                
        for f in files:
            if os.path.exists(f) and not os.path.isdir(f):
                pac_res = run_cmd(['pacman', '-Qo', f])
                pac_owner = pac_res.stdout.strip() if pac_res.returncode == 0 else None
                
                dpkg_res = run_cmd(['dpkg', '-S', f])
                dpkg_owner = dpkg_res.stdout.strip() if dpkg_res.returncode == 0 else None
                
                if dpkg_owner:
                    conflicts.append((pkg, f, f"Owned by dpkg: {{dpkg_owner}}"))
                elif pac_owner:
                    pass
                else:
                    conflicts.append((pkg, f, "Unowned existing file (Franken-risk)"))
                    
    if conflicts:
        print("")
        print("="*50)
        print("CONFLICT DIAGNOSTICS REPORT")
        print("="*50)
        print("DANGER: The following files conflict with existing packages or unmanaged files.")
        print("Proceeding would create a franken-system or corrupt dpkg databases.")
        print("")
        for pkg, f, reason in conflicts:
            print(f"[{{pkg}}] {{f}} -> {{reason}}")
        print("")
        print("Installation aborted safely.")
        sys.exit(1)
    else:
        print("No conflicts detected. Safe to proceed.")

def main():
    args = sys.argv[1:]
    if not args:
        run_cmd(['pacman'], capture=False)
        return

    is_install = False
    packages = []
    
    if args[0].startswith('-S') or args[0].startswith('-U'):
        if 'y' not in args[0] and 'u' not in args[0] and len(args) > 1 and not args[0].startswith('-Sq') and not args[0].startswith('-Ss') and not args[0].startswith('-Sc') and not args[0].startswith('-Sw'):
            is_install = True
            for arg in args[1:]:
                if not arg.startswith('-'):
                    packages.append(arg)
                    
    if is_install and packages:
        check_conflicts(packages)
        print("")
        print("Executing pacman...")
        run_cmd(['pacman'] + args, capture=False)
    else:
        run_cmd(['pacman'] + args, capture=False)

if __name__ == '__main__':
    main()
"""
    with open(safe_pacman_path, 'w') as f:
        f.write(script_content)
    
    safe_pacman_path.chmod(0o755)
    print(f"[*] Set executable permissions on {safe_pacman_path}")

def clear_cache():
    print("[*] Clearing pacman package cache...")
    run_cmd(["pacman", "-Scc", "--noconfirm"])

def main():
    print("=== Starting Safe Pacman Deployment for Termux ===")
    install_pacman()
    setup_pacman()
    deploy_safe_pacman()
    clear_cache()
    
    print("")
    print("=== Deployment Successful ===")
    print("You can now install pacman packages without destroying your system by using:")
    print("    safe-pacman -S <package_name>")
    print("")
    print("Make sure ~/.local/bin is in your PATH!")

if __name__ == "__main__":
    main()
