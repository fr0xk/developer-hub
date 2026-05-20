import subprocess
import shutil
import os
import logging
import json
import re

LOG_FILE = os.path.expanduser("~/.updates.log")

ENV = {
    **os.environ,
    "DEBIAN_FRONTEND": "noninteractive",
    "APT_LISTCHANGES_FRONTEND": "none"
}

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def log(msg):
    print(msg)
    logging.info(msg)

def exists(cmd):
    return shutil.which(cmd) is not None

def run(cmd, capture=True):
    log("Running: " + " ".join(cmd))
    p = subprocess.run(
        cmd,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
        text=True,
        env=ENV
    )
    if capture and p.stdout:
        print(p.stdout)
    if p.returncode != 0:
        logging.error("Exit code %s", p.returncode)
    return p.returncode == 0, p.stdout if capture else ""

# -----------------------------
# REPAIR & MIRRORS
# -----------------------------

def repair_repos():
    log("Checking repository health...")
    ok, out = run(["apt", "update"])
    
    if not ok and ("Hash Sum mismatch" in out or "tur" in out.lower()):
        log("TUR index failure detected. Attempting to reset tur-repo...")
        run(["apt", "clean"])
        run(["apt", "install", "--reinstall", "tur-repo", "-y"])
        ok, _ = run(["apt", "update"])

    if not ok:
        log("Still failing. Trying to switch to official mirror...")
        run(["sed", "-i", "s|https://mirrors.krnk.org/apt/termux/termux-main|https://packages.termux.dev/apt/termux-main|", "/data/data/com.termux/files/usr/etc/apt/sources.list"])
        ok, _ = run(["apt", "update"])
    
    return ok

# -----------------------------
# PYTHON / PIP (ADAPTED)
# -----------------------------

def update_python_ecosystem():
    pip_cmd = shutil.which("pip") or shutil.which("pip3")
    if not pip_cmd:
        return

    log("Updating Python ecosystem (prioritizing APT)...")
    
    # 1. Check for outdated pip packages
    ok, out = run([pip_cmd, "list", "--outdated", "--format=json"])
    if not ok: return
    try:
        outdated = json.loads(out)
    except: return
    
    pip_names = [p["name"] for p in outdated]
    if not pip_names:
        log("All PIP packages up to date.")
        return

    # 2. Try to find APT equivalents for outdated PIP packages
    apt_equivalents = []
    pure_pip = []
    
    for name in pip_names:
        # Check if python-NAME exists in apt
        apt_name = f"python-{name.lower()}"
        ok, _ = run(["apt-cache", "show", apt_name])
        if ok:
            apt_equivalents.append(apt_name)
        else:
            pure_pip.append(name)

    if apt_equivalents:
        log(f"Installing APT versions: {', '.join(apt_equivalents)}")
        run(["apt", "install", "-y"] + apt_equivalents)

    if pure_pip:
        log(f"Upgrading remaining via PIP: {', '.join(pure_pip)}")
        run([pip_cmd, "install", "-U"] + pure_pip)

    run([pip_cmd, "cache", "purge"])

# -----------------------------
# MAIN WORKFLOW
# -----------------------------

def main():
    log("Starting smart upgrade...")

    # System core
    run(["dpkg", "--configure", "-a"])
    if not repair_repos():
        log("Repository repair failed, but proceeding with caution...")

    # Upgrade system packages first
    run(["apt", "upgrade", "-y"])
    
    # Eco-systems
    update_python_ecosystem()
    
    if exists("npm"):
        log("Updating NPM...")
        run(["npm", "install", "-g", "npm@latest"])
        run(["npm", "update", "-g"])
        run(["npm", "cache", "clean", "--force"])

    if exists("go"):
        run(["go", "clean", "-modcache"])

    # Final cleanup
    run(["apt", "autoremove", "-y"])
    run(["apt", "clean"])
    
    log("Smart upgrade finished.")

if __name__ == "__main__":
    main()
