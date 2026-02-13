#!/usr/bin/env python3
import os
import re
import sys
import argparse


EXTENSIONS = {
    'c_style': ['.c', '.h', '.cpp', '.hpp', '.cc', '.cs', '.java', '.js', '.mjs', '.ts', '.go', '.rs', '.php', '.kt', '.swift', '.dart'],
    'hash_style': ['.py', '.rb', '.sh', '.bash', '.zsh', '.fish', '.pl', '.pm', '.yaml', '.yml', '.toml', '.conf', '.ini', '.mkshrc', '.ashrc', '.tcshrc'],
    'html_style': ['.html', '.xml', '.svg', '.htm'],
    'css_style': ['.css', '.scss', '.less']
}

IGNORE_DIRS = {'.git', 'node_modules', 'target', 'vendor', 'venv', '.cargo', '.rustup', 'go/pkg', '.npm', '.cache', '__pycache__'}

class CommentStripper:
    def __init__(self, dry_run=True):
        self.dry_run = dry_run
        self.stats = {'files_scanned': 0, 'files_modified': 0, 'comments_removed': 0}

    def strip_c_style(self, text):
        # Regex to match strings OR comments
        # Group 1: Double quoted string
        # Group 2: Single quoted string
        # Group 3: Block comment
        # Group 4: Line comment
        pattern = r'("(?:\\.|[^"\\])*")|(\'(?:\\.|[^"\\])*\')|(/\*[\s\S]*?\*/)|(//[^\r\n]*)'
        
        def replacer(match):
            if match.group(1) or match.group(2):
                return match.group(0) # Keep strings
            self.stats['comments_removed'] += 1
            return ' ' if match.group(3) else ''

        return re.sub(pattern, replacer, text)

    def strip_hash_style(self, text):
        # Python/Shell style
        # Group 1: Double quoted string
        # Group 2: Single quoted string
        # Group 3: Comment
        pattern = r'("(?:\\.|[^"\\])*")|(\'(?:\\.|[^"\\])*\')|(#.*)'
        
        def replacer(match):
            if match.group(1) or match.group(2):
                return match.group(0)
            self.stats['comments_removed'] += 1
            return ''

        return re.sub(pattern, replacer, text)

    def strip_html_style(self, text):
        # HTML style
        pattern = r'(<!--[\s\S]*?-->)'
        
        def replacer(match):
            self.stats['comments_removed'] += 1
            return ''

        return re.sub(pattern, replacer, text)

    def strip_css_style(self, text):
        # CSS style (only block comments)
        pattern = r'("(?:\\.|[^"\\])*")|(\'(?:\\.|[^"\\])*\')|(/\*[\s\S]*?\*/)'
        
        def replacer(match):
            if match.group(1) or match.group(2):
                return match.group(0)
            self.stats['comments_removed'] += 1
            return ' '

        return re.sub(pattern, replacer, text)

    def process_file(self, filepath):
        ext = os.path.splitext(filepath)[1].lower()
        style = None
        
        for s, exts in EXTENSIONS.items():
            if ext in exts:
                style = s
                break
        
        if not style:
            return

        self.stats['files_scanned'] += 1
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                original = f.read()
        except Exception as e:
            print(f"[!] Error reading {filepath}: {e}")
            return

        
        header = ""
        content = original
        if original.startswith("#!"):
            if '\n' in original:
                header, content = original.split('\n', 1)
                header += '\n'
            else:
                return # Single line shebang only

        new_content = content
        if style == 'c_style':
            new_content = self.strip_c_style(content)
        elif style == 'hash_style':
            new_content = self.strip_hash_style(content)
        elif style == 'html_style':
            new_content = self.strip_html_style(content)
        elif style == 'css_style':
            new_content = self.strip_css_style(content)

        final_output = header + new_content

        if final_output != original:
            self.stats['files_modified'] += 1
            if self.dry_run:
                print(f"[DRY-RUN] Would modify: {filepath}")
            else:
                try:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(final_output)
                    print(f"[MODIFIED] {filepath}")
                except Exception as e:
                    print(f"[!] Error writing {filepath}: {e}")

    def scan_directory(self, root_dir):
        for root, dirs, files in os.walk(root_dir):
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS and not d.startswith('.')]
            
            for file in files:
                if file.startswith('.'): continue
                self.process_file(os.path.join(root, file))

    def print_report(self):
        print("\n" + "="*30)
        print(f"REPORT ({'DRY RUN' if self.dry_run else 'EXECUTION'})")
        print("="*30)
        print(f"Files Scanned:      {self.stats['files_scanned']}")
        print(f"Files to Modify:    {self.stats['files_modified']}")
        print(f"Comments Detected:  {self.stats['comments_removed']}")
        print("="*30)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Universal Comment Stripper")
    parser.add_argument("--path", default=".", help="Root directory to scan")
    parser.add_argument("--force", action="store_true", help="Execute permanent changes")
    
    args = parser.parse_args()
    
    stripper = CommentStripper(dry_run=not args.force)
    stripper.scan_directory(os.path.abspath(args.path))
    stripper.print_report()
