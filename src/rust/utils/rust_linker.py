#!/usr/bin/env python3
import os
import sys
import subprocess
import argparse
import glob
import re

class RustLinker:
    
    DEFAULT_EDITION = "2021"
    DEFAULT_OUTPUT = "rust_binary"
    LIB_PATTERN = "*.rlib"
    PREFIX = "lib"
    SUFFIX = ".rlib"
    
    def __init__(self, lib_dir, source_file, output_name=None, edition=None):
        self.lib_dir = os.path.abspath(lib_dir)
        self.source_file = os.path.abspath(source_file)
        self.output_name = output_name or self.DEFAULT_OUTPUT
        self.edition = edition or self.DEFAULT_EDITION
        self.crate_map = {}

    def _parse_crate_name(self, filename):
        """
        Extracts the logical crate name from a hashed rlib filename.
        Example: libserde_json-1234abcd.rlib -> serde_json
        """
        
        core = filename[len(self.PREFIX):-len(self.SUFFIX)]
        
        
        
        if '-' in core:
            name_parts = core.rsplit('-', 1)
            return name_parts[0]
        return core

    def scan_libraries(self):
        """Builds a map of crate names to their absolute rlib paths."""
        if not os.path.exists(self.lib_dir):
            raise FileNotFoundError(f"Library directory not found: {self.lib_dir}")

        search_path = os.path.join(self.lib_dir, self.LIB_PATTERN)
        for path in glob.glob(search_path):
            filename = os.path.basename(path)
            crate_name = self._parse_crate_name(filename)
            
            self.crate_map[crate_name] = os.path.abspath(path)
        
        return len(self.crate_map)

    def build_command(self, optimize=False, verbose=False):
        """Constructs the rustc command list."""
        cmd = [
            "rustc",
            "--edition", self.edition,
            "-L", f"dependency={self.lib_dir}"
        ]

        if optimize:
            cmd.append("-O")

        
        for name, path in self.crate_map.items():
            cmd.extend(["--extern", f"{name}={path}"])

        
        cmd.extend([self.source_file, "-o", self.output_name])
        return cmd

    def execute(self, optimize=False, verbose=False):
        """Runs the compilation process."""
        try:
            num_libs = self.scan_libraries()
            print(f"[*] Found {num_libs} crates in pool.")
            
            cmd = self.build_command(optimize, verbose)
            
            if verbose:
                print(f"[DEBUG] Command: {' '.join(cmd)}\n")

            print(f"[*] Compiling {os.path.basename(self.source_file)}...")
            subprocess.run(cmd, check=True)
            print(f"[+] Success: ./{self.output_name}")
            
        except Exception as e:
            print(f"[!] Error: {e}")
            sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description="Suckless Rust Linker - Manual rustc orchestration without Cargo."
    )
    
    
    parser.add_argument("source", help="Path to the .rs source file")
    parser.add_argument("-l", "--lib-dir", required=True, 
                        help="Path to the directory containing .rlib files")
    
    
    parser.add_argument("-o", "--output", help="Output binary name")
    parser.add_argument("-e", "--edition", help="Rust edition (default: 2021)")
    parser.add_argument("-opt", "--optimize", action="store_true", help="Enable optimizations")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print the raw rustc command")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    
    linker = RustLinker(
        lib_dir=args.lib_dir,
        source_file=args.source,
        output_name=args.output,
        edition=args.edition
    )
    
    linker.execute(optimize=args.optimize, verbose=args.verbose)

if __name__ == "__main__":
    main()
