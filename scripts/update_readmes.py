#!/usr/bin/env python3
import os
import re
from pathlib import Path

# Mapping of known files to their descriptions
FILE_DESCRIPTIONS = {
    "governor.rs": "System resource/governor controller",
    "news.rs": "Rust-based news headline fetcher",
    "app_manager.py": "Application management utility",
    "control.py": "System control and automation script",
    "rsb.py": "Rust build/staging utility",
    "rust_linker.py": "Rust toolchain linking utility",
    "strip_comments.py": "Code comment removal tool",
    "requirements.txt": "Python dependencies for the workspace",
    "generate_docs.sh": "Documentation generation script",
    "make_artifact.sh": "Artifact creation/bundling script",
    "scripts_env.sh": "Environment configuration for scripts",
    "clang_tidy_check.sh": "Rust/C++ linting utility",
    "build_python.sh": "Python build helper",
    "virtual_env_fish.fish": "Fish shell virtualenv manager",
    "tool.py": "Python CLI tool template",
}

IGNORE_LIST = [".git", "__pycache__", "target", "README.md", "Cargo.lock", "Cargo.toml", ".gitignore", "vendor", "docs", "assets", "templates", "docs"]
CONTENT_HEADERS = ["## Contents", "## Included Files"]

def get_file_list(directory, header_name):
    items = []
    for item in sorted(os.listdir(directory)):
        if item in IGNORE_LIST:
            continue
        path = Path(directory) / item
        desc = FILE_DESCRIPTIONS.get(item, "Script or utility module" if path.is_file() else "Directory")
        items.append(f"- `{item}`: {desc}.")
    return header_name + "\n\n" + "\n".join(items) + "\n"

def update_readme(readme_path, repo_root):
    if not readme_path.exists():
        return

    content = readme_path.read_text()
    
    if "<!-- no-auto -->" in content:
        return

    found_header = None
    for header in CONTENT_HEADERS:
        if header in content:
            found_header = header
            break
    
    rel_path = readme_path.resolve().relative_to(repo_root)

    if not found_header:
        return

    dir_path = readme_path.parent
    new_contents_block = get_file_list(dir_path, found_header)

    pattern_str = re.escape(found_header) + r"[\s\S]*?(?=\n#|$)"
    pattern = re.compile(pattern_str)
    
    if pattern.search(content):
        new_content = pattern.sub(new_contents_block.replace("\\", "\\\\"), content, count=1)
        
        footer = "\n---\n*Generated automatically by Developer Hub Doc-Manager*"
        if footer not in new_content:
            new_content = new_content.strip() + footer + "\n"
            
        if new_content != content:
            print(f" [*] Updating {rel_path}")
            readme_path.write_text(new_content)
        else:
            print(f" [ok] {rel_path} is already up to date.")
    else:
        print(f" [!] Failed to match pattern in {rel_path}")

def main():
    repo_root = Path(__file__).resolve().parent.parent.resolve()
    os.chdir(repo_root)
    for root, dirs, files in os.walk("."):
        if ".git" in root or "vendor" in root or "docs" in root:
            continue
        if "README.md" in files:
            update_readme(Path(root).resolve() / "README.md", repo_root)

if __name__ == "__main__":
    main()
