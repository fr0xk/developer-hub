#!/usr/bin/env python3
import argparse
import os
import subprocess
import shutil
import sys
import platform
from pathlib import Path




class Deployer:
    def __init__(self, args):
        self.args = args
        self.home = Path.home()
        self.repo_dir = self.home / "personalDotfiles"
        self.ai_dir = self.home / "ai_workspace"
        self.is_termux = "com.termux" in os.environ.get("PREFIX", "")

    def run(self, cmd, check=True):
        print(f"Executing: {' '.join(cmd)}")
        try:
            return subprocess.run(cmd, check=check, text=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"Error: {e.stdout}\n{e.stderr}")
            if check: sys.exit(1)
            return e

    def setup_system(self):
        print("--- Setting up System Packages ---")
        if self.is_termux:
            
            self.run(["pkg", "update", "-y"])
            self.run(["pkg", "install", "-y", "git", "gh", "node-js", "python", "golang", "build-essential", "git-crypt"])
            
            self.run(["pkg", "install", "-y", "tur-repo"])
        else:
            
            if shutil.which("apt-get"):
                self.run(["sudo", "apt-get", "update"])
                self.run(["sudo", "apt-get", "install", "-y", "git", "gh", "nodejs", "python3", "golang", "build-essential"])

    def setup_dotfiles(self):
        print("--- Setting up Dotfiles ---")
        if not self.repo_dir.exists():
            repo_url = self.args.repo or "git@github.com:fr0xk/personalDotfiles.git"
            self.run(["git", "clone", repo_url, str(self.repo_dir)])
        
        
        dotmanager = self.repo_dir / "deploy_env" / "dotmanager.py"
        if dotmanager.exists():
            self.run([sys.executable, str(dotmanager), "install"])
        
        
        if self.args.key and Path(self.args.key).exists():
            self.run(["git-crypt", "unlock", self.args.key], check=False)

    def setup_ai_workspace(self):
        print("--- Setting up AI Workspace ---")
        self.ai_dir.mkdir(exist_ok=True)
        os.chdir(self.ai_dir)

        if self.is_termux:
            
            self.run(["pkg", "install", "-y", "python-numpy", "python-pandas", "python-scipy"])
        
        
        req_file = Path(__file__).parent / "requirements.txt"
        if req_file.exists():
            
            
            
            self.run([sys.executable, "-m", "pip", "install", "-r", str(req_file)])
        
        
        if not (self.ai_dir / "go.mod").exists():
            self.run(["go", "mod", "init", "ai_projects"], check=False)
            self.run(["go", "get", "gonum.org/v1/gonum/..."])

    def setup_gemini_cli(self):
        print("--- Setting up Gemini CLI ---")
        self.run(["npm", "install", "-g", "@mmmbuto/gemini-cli-termux@latest"])

    def verify(self):
        print("--- Verifying Environment ---")
        checks = {
            "Git": shutil.which("git"),
            "GitHub CLI": shutil.which("gh"),
            "Node.js": shutil.which("node"),
            "Python": shutil.which("python"),
            "Go": shutil.which("go"),
            "Gemini CLI": shutil.which("gemini"),
            "Dotfiles Repo": self.repo_dir.exists(),
            "AI Workspace": self.ai_dir.exists(),
        }

        all_passed = True
        for name, status in checks.items():
            mark = "✅" if status else "❌"
            print(f"{mark} {name}")
            if not status: all_passed = False

        
        print("\nChecking Python AI Libraries...")
        libs = ["numpy", "pandas", "scipy", "nltk"]
        req_file = Path(__file__).parent / "requirements.txt"
        if req_file.exists():
            with open(req_file, "r") as f:
                libs = list(set(libs + [line.strip().split('==')[0] for line in f if line.strip() and not line.startswith("#")]))
        
        for lib in libs:
            
            import_name = "sklearn" if lib == "scikit-learn" else lib
            try:
                __import__(import_name)
                print(f"✅ {import_name}")
            except ImportError:
                if self.is_termux and import_name == "sklearn":
                    print(f"⚠️  {import_name} (Optional/Hard to build on Termux)")
                else:
                    print(f"❌ {import_name}")
                    all_passed = False

        if all_passed:
            print("\n✨ Environment is PROPERLY set up!")
        else:
            print("\n⚠️ Environment has MISSING components. Run with --all to fix.")

    def deploy(self):
        if self.args.verify:
            self.verify()
            return
        if self.args.all or self.args.system:
            self.setup_system()
        if self.args.all or self.args.dotfiles:
            self.setup_dotfiles()
        if self.args.all or self.args.ai:
            self.setup_ai_workspace()
        if self.args.all or self.args.cli:
            self.setup_gemini_cli()
        
        print("\n🚀 Deployment Complete!")

def main():
    parser = argparse.ArgumentParser(description="Rapid Deployment Tool for Termux/Linux AI Environment")
    parser.add_argument("--verify", action="store_true", help="Verify current environment setup")
    parser.add_argument("--all", action="store_true", help="Deploy everything")
    parser.add_argument("--system", action="store_true", help="Install system packages")
    parser.add_argument("--dotfiles", action="store_true", help="Clone and install dotfiles")
    parser.add_argument("--ai", action="store_true", help="Setup AI workspace and libs")
    parser.add_argument("--cli", action="store_true", help="Install Gemini CLI")
    parser.add_argument("--repo", type=str, help="Custom dotfiles repo URL")
    parser.add_argument("--key", type=str, help="Path to git-crypt key")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()
    deployer = Deployer(args)
    deployer.deploy()

if __name__ == "__main__":
    main()
