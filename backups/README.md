# Package Backup Manifest

This directory contains **explicitly installed package names** (not binaries or versions) from your Termux environment, captured for reproducibility and disaster recovery.

> 🔒 **Security note**: These files contain *only package names*, no secrets, paths, or sensitive config. They are safe to commit to Git.

---

## 📋 Files

| File                     | Source          | Count | Notes |
|--------------------------|-----------------|-------|-------|
| `termux-packages.txt`    | Termux `pkg`    | 105   | Explicitly installed (i.e., not auto-installed dependencies). Detected by absence of `[installed,automatic]` in `pkg list-installed`. |
| `pip-packages.txt`       | Python `pip`    | 20    | Explicitly installed via `pip install` (not dependencies). Collected with `pip list --not-required`. |
| `npm-packages.txt`       | Node.js `npm`   | 0     | No globally installed packages found (`npm ls -g --depth=0`). |
| `cargo-packages.txt`     | Rust `cargo`    | 0     | No installed crates found (`cargo install --list`). |

---

## 🛠️ How It Works

The backup was generated using [`backup.py`](../backup.py), which:

1. **Detects explicit packages** by:
   - Termux: filtering `pkg list-installed` for lines *without* `automatic`
   - pip: using `--not-required`
   - npm/cargo: parsing top-level output of `npm ls -g --depth=0` / `cargo install --list`

2. **Stores only package names** (no versions) because:
   - Termux & npm don’t reliably expose version+hash for reinstallation in scripts
   - `pip freeze` includes dependencies; `--not-required` gives clean explicit list
   - Reinstalling latest is usually safe; if exact versions are needed, use `pip freeze > requirements.txt` separately

3. **Preserves idempotency**: Running `--backup` again updates the lists; `--sync` reports drift.

---

## 🔄 Usage

### 1. Backup current state
```bash
python3 backup.py --backup
```

### 2. Restore packages (⚠️ requires confirmation)
```bash
python3 backup.py --restore
```
> This runs:
> - `pkg install -y <termux-packages>`
> - `pip install <pip-packages>`
> - `npm install -g <npm-packages>`
> - `cargo install <cargo-packages>`

### 3. Sync & check for changes
```bash
python3 backup.py --sync
```
> Reports added/removed packages vs previous backup.

---

## ⚠️ Limitations

- **No version pinning**: For reproducible environments, supplement with:
  - `pip freeze > requirements.txt`
  - `npm list -g --depth=0 --json > npm-list.json`
  - Manual `cargo.toml` for Rust projects
- Termux auto-installed packages (e.g., dependencies of explicitly installed ones) are *excluded* by design.
- If you use `termux-setup-storage`, `git`, etc. as explicit installs, they appear here.

---

## 📦 Maintained By
Qwen Code — generated on **2026-02-14**  
Script: [`backup.py`](../backup.py)  
Git commit: `878a528d`

> 💡 Tip: Add this to your dotfiles sync workflow!