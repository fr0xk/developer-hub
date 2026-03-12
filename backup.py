#!/data/data/com.termux/files/usr/bin/python3
"""
Termux/NPM/Cargo/Pip Explicit Package Backup & Restore Script

Features:
  - backup: saves explicitly installed package names (no versions, unless available & safe)
  - restore: reinstalls packages (user confirmation required)
  - sync: re-backs up, reports changes

Usage:
  python3 backup.py --backup
  python3 backup.py --restore
  python3 backup.py --sync

Outputs to ./backups/:
  termux-packages.txt
  npm-packages.txt
  pip-packages.txt
  cargo-packages.txt
"""

import os
import sys
import subprocess
import argparse
import re
from pathlib import Path

def run_cmd(cmd, check=True, capture=True):
    """Run shell command, return stdout or (stdout, stderr)"""
    # Check if the base command exists before running
    base_cmd = cmd.split()[0]
    if subprocess.run(f"command -v {base_cmd}", shell=True, capture_output=True).returncode != 0:
        return "", f"Command '{base_cmd}' not found"
    
    try:
        if capture:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
            if check and result.returncode != 0:
                raise RuntimeError(f"Command failed: {cmd}\nstderr: {result.stderr.strip()}")
            return result.stdout.strip(), result.stderr.strip()
        else:
            subprocess.run(cmd, shell=True, check=check, timeout=30)
            return "", ""
    except subprocess.TimeoutExpired:
        raise RuntimeError(f"Command timed out: {cmd}")
    except Exception as e:
        raise RuntimeError(f"Error running '{cmd}': {e}")

def ensure_backups_dir():
    backups_dir = Path("backups")
    backups_dir.mkdir(exist_ok=True)
    return backups_dir

# --- Termux ---
def get_termux_packages():
    """Get explicitly installed packages: lines WITHOUT 'automatic' in status"""
    try:
        stdout, _ = run_cmd("pkg list-installed")
        pkgs = []
        for line in stdout.splitlines():
            line = line.strip()
            if not line or line.startswith('Listing') or line.startswith('Package'):
                continue
            # Format: "name/stable,now version arch [installed]" or "[installed,automatic]"
            if '[installed,automatic]' in line:
                continue  # skip auto-installed
            if '[installed]' in line:
                # Extract package name: before '/'
                pkg_match = re.match(r'^([^/\s]+)', line)
                if pkg_match:
                    pkgs.append(pkg_match.group(1))
        return sorted(set(pkgs))
    except Exception as e:
        print(f"⚠️  Termux package list failed: {e}", file=sys.stderr)
        return []

# --- npm ---
def get_npm_packages():
    """Get globally installed packages (explicit only) via 'npm ls -g --depth=0'"""
    try:
        stdout, _ = run_cmd("npm ls -g --depth=0")
        pkgs = []
        for line in stdout.splitlines():
            line = line.strip()
            if line.startswith('├── ') or line.startswith('└── '):
                part = line[4:].strip()
                if '@' in part:
                    pkg_name = part.split('@')[0]
                else:
                    pkg_name = part
                if pkg_name and not pkg_name.startswith('npm'):
                    pkgs.append(pkg_name)
        return sorted(set(pkgs))
    except Exception as e:
        print(f"⚠️  npm package list failed: {e}", file=sys.stderr)
        return []

# --- pip ---
def get_pip_packages():
    """Get explicitly installed packages via 'pip list --not-required'"""
    try:
        stdout, _ = run_cmd("pip list --not-required --format=freeze")
        pkgs = []
        for line in stdout.splitlines():
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '==' in line:
                pkg_name = line.split('==')[0]
            else:
                pkg_name = line
            if pkg_name:
                pkgs.append(pkg_name)
        return sorted(set(pkgs))
    except Exception as e:
        print(f"⚠️  pip package list failed: {e}", file=sys.stderr)
        return []

# --- cargo ---
def get_cargo_packages():
    """Get installed crates via 'cargo install --list'"""
    try:
        stdout, _ = run_cmd("cargo install --list")
        pkgs = []
        for line in stdout.splitlines():
            line = line.strip()
            if not line or line.startswith('Installed') or line.startswith('No packages'):
                continue
            if ' v' in line:
                pkg_name = line.split(' v')[0].strip()
            else:
                pkg_name = line
            if pkg_name:
                pkgs.append(pkg_name)
        return sorted(set(pkgs))
    except Exception as e:
        print(f"⚠️  cargo package list failed: {e}", file=sys.stderr)
        return []

def write_packages(filename, pkgs):
    path = Path("backups") / filename
    with open(path, "w") as f:
        f.write("\n".join(pkgs) + "\n")
    print(f"✅ Saved {len(pkgs)} packages to {path}")

def backup():
    print("🔍 Collecting explicitly installed packages...")
    termux_pkgs = get_termux_packages()
    npm_pkgs = get_npm_packages()
    pip_pkgs = get_pip_packages()
    cargo_pkgs = get_cargo_packages()

    ensure_backups_dir()
    write_packages("termux-packages.txt", termux_pkgs)
    write_packages("npm-packages.txt", npm_pkgs)
    write_packages("pip-packages.txt", pip_pkgs)
    write_packages("cargo-packages.txt", cargo_pkgs)

    print("\n📦 Backup complete.")
    print(f"  Termux: {len(termux_pkgs)}")
    print(f"  npm:    {len(npm_pkgs)}")
    print(f"  pip:    {len(pip_pkgs)}")
    print(f"  cargo:  {len(cargo_pkgs)}")

def restore():
    backups_dir = Path("backups")
    if not backups_dir.exists():
        print("❌ Backups directory 'backups/' not found. Run --backup first.", file=sys.stderr)
        return

    termux_file = backups_dir / "termux-packages.txt"
    npm_file = backups_dir / "npm-packages.txt"
    pip_file = backups_dir / "pip-packages.txt"
    cargo_file = backups_dir / "cargo-packages.txt"

    def read_list(path):
        if not path.exists():
            return []
        return [line.strip() for line in path.read_text().splitlines() if line.strip()]

    termux_pkgs = read_list(termux_file)
    npm_pkgs = read_list(npm_file)
    pip_pkgs = read_list(pip_file)
    cargo_pkgs = read_list(cargo_file)

    total = len(termux_pkgs) + len(npm_pkgs) + len(pip_pkgs) + len(cargo_pkgs)
    if total == 0:
        print("❌ No packages to restore (empty backup files).")
        return

    print(f"⚠️  This will reinstall {total} packages:")
    print(f"  Termux: {len(termux_pkgs)}")
    print(f"  npm:    {len(npm_pkgs)}")
    print(f"  pip:    {len(pip_pkgs)}")
    print(f"  cargo:  {len(cargo_pkgs)}")
    confirm = input("Proceed? (y/N): ").strip().lower()
    if confirm != 'y':
        print("Aborted.")
        return

    print("\n🔄 Restoring...")

    if termux_pkgs:
        print("📦 Installing Termux packages...")
        cmd = f"pkg install -y {' '.join(termux_pkgs)}"
        try:
            run_cmd(cmd, check=True, capture=False)
        except Exception as e:
            print(f"❌ Termux install failed: {e}", file=sys.stderr)

    if npm_pkgs:
        print("📦 Installing npm packages...")
        cmd = f"npm install -g {' '.join(npm_pkgs)}"
        try:
            run_cmd(cmd, check=True, capture=False)
        except Exception as e:
            print(f"❌ npm install failed: {e}", file=sys.stderr)

    if pip_pkgs:
        print("📦 Installing pip packages...")
        cmd = f"pip install {' '.join(pip_pkgs)}"
        try:
            run_cmd(cmd, check=True, capture=False)
        except Exception as e:
            print(f"❌ pip install failed: {e}", file=sys.stderr)

    if cargo_pkgs:
        print("📦 Installing cargo crates...")
        for pkg in cargo_pkgs:
            try:
                run_cmd(f"cargo install {pkg}", check=True, capture=False)
            except Exception as e:
                print(f"❌ cargo install {pkg} failed: {e}", file=sys.stderr)

    print("\n✅ Restore complete.")

def sync():
    print("🔄 Syncing: backing up again and comparing with previous...")
    backups_dir = Path("backups")
    before = {}
    for fname in ["termux-packages.txt", "npm-packages.txt", "pip-packages.txt", "cargo-packages.txt"]:
        path = backups_dir / fname
        if path.exists():
            before[fname] = path.read_text().splitlines()
        else:
            before[fname] = []

    backup()  # overwrites backups/

    changed = []
    for fname in before:
        path = backups_dir / fname
        after = path.read_text().splitlines() if path.exists() else []
        if before[fname] != after:
            added = set(after) - set(before[fname])
            removed = set(before[fname]) - set(after)
            if added or removed:
                changed.append((fname, sorted(added), sorted(removed)))

    if changed:
        print("\n📝 Changes detected:")
        for fname, added, removed in changed:
            print(f"  {fname}:")
            if added:
                print(f"    + {len(added)} new: {', '.join(added[:5])}{'...' if len(added)>5 else ''}")
            if removed:
                print(f"    - {len(removed)} removed: {', '.join(removed[:5])}{'...' if len(removed)>5 else ''}")
    else:
        print("\n✅ No changes — already synced.")

def main():
    parser = argparse.ArgumentParser(description="Backup/restore explicitly installed packages")
    parser.add_argument("--backup", action="store_true", help="Backup package lists")
    parser.add_argument("--restore", action="store_true", help="Restore from backups (requires confirmation)")
    parser.add_argument("--sync", action="store_true", help="Backup and report changes")
    args = parser.parse_args()

    if args.backup:
        backup()
    elif args.restore:
        restore()
    elif args.sync:
        sync()
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()