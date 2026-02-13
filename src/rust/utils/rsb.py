#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
import argparse
import glob

class RustSuckless:
    
    COMPILER = "rustc"
    EDITION = "2021"
    LIB_PREFIX = "lib"
    LIB_EXT = ".rlib"
    
    
    BASE_FLAGS = ["--edition", EDITION]
    OPT_FLAGS = ["-O", "-C", "panic=abort", "-C", "lto=yes"]
    
    def __init__(self, crate_pool=None):
        self.cwd = os.getcwd()
        
        self.crate_pool = os.path.abspath(crate_pool) if crate_pool else None
        self.local_libs = os.path.join(self.cwd, "libs")
        self.output_dir = os.path.join(self.cwd, "dist")

    def _ensure_dirs(self):
        """Prepare local project structure."""
        os.makedirs(self.local_libs, exist_ok=True)
        os.makedirs(self.output_dir, exist_ok=True)

    def _get_crate_name(self, path):
        """Clean name from libabc-hash.rlib -> abc"""
        fname = os.path.basename(path)
        core = fname[len(self.LIB_PREFIX):-len(self.LIB_EXT)]
        return core.rsplit('-', 1)[0] if '-' in core else core

    def compile_lib(self, source_file, optimize=False):
        """Compile a local .rs file into a .rlib library."""
        self._ensure_dirs()
        name = os.path.splitext(os.path.basename(source_file))[0]
        dest = os.path.join(self.local_libs, f"{self.LIB_PREFIX}{name}{self.LIB_EXT}")
        
        cmd = [self.COMPILER] + self.BASE_FLAGS + ["--crate-type=lib", source_file, "-o", dest]
        if optimize: cmd.extend(self.OPT_FLAGS)
        
        print(f"[*] Building Library: {name}...")
        subprocess.run(cmd, check=True)
        return name, dest

    def fetch_dependencies(self, source_code):
        """
        Scan source code for crate names and copy matching 
        .rlib files from the Pool to the local project.
        """
        if not self.crate_pool:
            return

        pool_files = glob.glob(os.path.join(self.crate_pool, f"*{self.LIB_EXT}"))
        
        for path in pool_files:
            crate_name = self._get_crate_name(path)
            
            if crate_name in source_code:
                dest = os.path.join(self.local_libs, os.path.basename(path))
                if not os.path.exists(dest):
                    print(f"[+] Fetching: {crate_name}")
                    shutil.copy(path, dest)

    def build_bin(self, main_rs, output_name="app", optimize=False, verbose=False):
        """Compile the final binary, linking all local and fetched libs."""
        self._ensure_dirs()
        
        with open(main_rs, 'r') as f:
            self.fetch_dependencies(f.read())

        cmd = [self.COMPILER] + self.BASE_FLAGS
        if optimize: cmd.extend(self.OPT_FLAGS)

        libs = glob.glob(os.path.join(self.local_libs, f"*{self.LIB_EXT}"))
        for lib in libs:
            name = self._get_crate_name(lib)
            cmd.extend(["--extern", f"{name}={lib}"])
        
        cmd.extend(["-L", f"dependency={self.local_libs}"])
        cmd.extend([main_rs, "-o", os.path.join(self.output_dir, output_name)])

        if verbose: print(f"
[DEBUG] {' '.join(cmd)}
")
        
        print(f"[*] Compiling Binary: {output_name}...")
        subprocess.run(cmd, check=True)
        print(f"[#] Done! Binary created in {self.output_dir}/")

def main():
    parser = argparse.ArgumentParser(description="Suckless Rust Build System")
    parser.add_argument("action", choices=["lib", "bin", "ship"], help="Target action")
    parser.add_argument("source", help="Source .rs file")
    parser.add_argument("-p", "--pool", help="Source of external .rlib files")
    parser.add_argument("-o", "--out", help="Output filename")
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-opt", "--optimize", action="store_true")

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()
    rsb = RustSuckless(crate_pool=args.pool)

    try:
        if args.action == "lib":
            rsb.compile_lib(args.source, args.optimize)
        else:
            rsb.build_bin(args.source, args.out or "app", args.optimize, args.verbose)
    except Exception as e:
        print(f"[!] Error: {e}")

if __name__ == "__main__":
    main()
