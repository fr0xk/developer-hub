# Developer Hub

A smart, consolidated monorepo for developer tools, handbook resources, and automation scripts.

<!-- no-auto -->

## Directory Structure
- `rust/`: Core Rust projects and standalone utilities.
- `python/`: Automation, AI modules, and general utilities.
- `templates/`: Boilerplate templates for Python and Rust.
- `scripts/`: Shell scripts, maintenance, and documentation tools.
- `assets/`: Project resources and data files.
- `docs/`: Automatically generated system documentation.

## Maintenance
- **Commit Guidelines**: See [CONTRIBUTING.md](./CONTRIBUTING.md).
- **Documentation**: Documentation is automatically updated on every `git commit` via a pre-commit hook. You can also run `./scripts/generate_docs.sh` manually.
- **Versioning**: Use `git tag` for releases.

## Automation
- **Doc-Manager**: A Python script (`scripts/update_readmes.py`) automatically synchronizes `## Contents` sections in all `README.md` files with the actual filesystem.
- **Git Hooks**: Integrated `pre-commit` hook ensures documentation never goes out of sync.
