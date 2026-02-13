#!/usr/bin/env python3
"""
Suckless Dotfile Manager (2026 Edition)
A single-file, zero-dependency Python script to Backup & Install dotfiles.
Supports: Linux, macOS, Windows, Termux, FreeBSD.
"""

import argparse
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path





DOTFILES = {
    ".bashrc": None,
    ".zshrc": None,
    ".vimrc": None,
    ".tmux.conf": "_tmux.conf",  
    ".gitconfig": None,
    ".termux": None,  
    ".config/fish": None,
    ".config/htop": None,
    ".config/mpv": None,
    ".config/nvim": None,
    ".config/alacritty": None,
    ".config/starship.toml": None,
}


PKG_DIR = "packages"
PKG_COMMANDS = {
    "termux": ("pkg list-installed", "termux_pkg.txt"),
    "pip": ("pip freeze", "pip_requirements.txt"),
    "npm": ("npm list -g --depth=0", "npm_globals.txt"),
    
}


IGNORE_PATTERNS = [
    "__pycache__",
    ".git",
    ".DS_Store",
    "*.log",
    "*.tmp",
    "id_rsa",
    "id_ed25519",
    "known_hosts",  
    "history",
    ".history",
]




def get_home():
    """Returns the correct home directory for the current OS."""
    return Path.home()


def get_repo_root():
    """Returns the directory containing this script's parent (python/..)."""
    return Path(__file__).parent.parent.resolve()


def is_ignored(path):
    """Check if file matches ignore patterns."""
    name = path.name
    for pattern in IGNORE_PATTERNS:
        if "*" in pattern:
            if name.endswith(pattern.replace("*", "")):
                return True
        elif name == pattern:
            return True
    return False


def copy_recursive(src, dst):
    """Suckless recursive copy with ignore list."""
    if not src.exists():
        return False

    if src.is_file():
        if is_ignored(src):
            return False
        
        
        if dst.exists() and os.path.samefile(src, dst):
            return True

        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        print(f"📄 Copied: {src} -> {dst}")
        return True

    if src.is_dir():
        copied_any = False
        dst.mkdir(parents=True, exist_ok=True)
        for item in src.iterdir():
            if is_ignored(item):
                continue
            dest_item = dst / item.name
            if copy_recursive(item, dest_item):
                copied_any = True
        return copied_any

    return False


def backup_packages(repo):
    """Backup installed package lists."""
    print("📦 Backing up package lists...")
    pkg_dir = repo / PKG_DIR
    pkg_dir.mkdir(exist_ok=True)

    
    is_termux = "com.termux" in os.environ.get("PREFIX", "")

    for key, (cmd, filename) in PKG_COMMANDS.items():
        
        if key == "termux" and not is_termux:
            continue

        outfile = pkg_dir / filename
        try:
            
            exe = cmd.split()[0]
            if not shutil.which(exe):
                continue

            print(f"   Listing {key} -> {PKG_DIR}/{filename}")
            import shlex

            with open(outfile, "w") as f:
                subprocess.run(
                    shlex.split(cmd), shell=False, stdout=f, stderr=subprocess.DEVNULL
                )
        except Exception as e:
            print(f"   ⚠️ Failed to list {key}: {e}")


def backup(home, repo):
    """Backup: Home System -> Git Repo"""
    print(f"🔄 Backing up from {home} to {repo}...")

    
    count = 0
    for home_rel, repo_rel in DOTFILES.items():
        if repo_rel is None:
            repo_rel = home_rel

        src = home / home_rel
        dst = repo / repo_rel

        if src.exists():
            if copy_recursive(src, dst):
                count += 1
        else:
            
            pass

    
    backup_packages(repo)

    print(f"✅ Backup complete. {count} dotfiles processed.")


def install(home, repo, dry_run=False):
    """Install: Git Repo -> Home System"""
    print(f"🚀 Installing from {repo} to {home}...")
    if dry_run:
        print("(Dry Run Mode)")

    count = 0
    for home_rel, repo_rel in DOTFILES.items():
        if repo_rel is None:
            repo_rel = home_rel

        src = repo / repo_rel
        dst = home / home_rel

        if not src.exists():
            continue

        if dry_run:
            print(f"[Dry] Would install: {src} -> {dst}")
            continue

        
        
        

        if copy_recursive(src, dst):
            count += 1
            
            if platform.system() != "Windows":
                if dst.suffix in [".sh", ".py", ".pl"]:
                    os.chmod(dst, 0o700)

    print(f"✅ Installation complete. {count} items processed.")


def main():
    parser = argparse.ArgumentParser(description="Suckless Dotfile Manager")
    parser.add_argument(
        "action", choices=["backup", "install"], help="Action to perform"
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate install")

    args = parser.parse_args()

    home = get_home()
    repo = get_repo_root()

    if args.action == "backup":
        backup(home, repo)
    elif args.action == "install":
        install(home, repo, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
