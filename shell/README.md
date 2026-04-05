# rust-env-setup.sh

Portable Rust environment setup script with undo support. Works across Linux, macOS, and Termux (Android).

## Quick Start

```bash
# Install Rust, remove Go, configure shells
./rust-env-setup.sh setup

# Same but start in offline mode (saves data)
./rust-env-setup.sh setup-offline
```

## Commands

| Command | Description |
|---|---|
| `setup` | Install Rust, remove Go, add aliases, scaffold project |
| `setup-offline` | Same as setup, but defaults to offline mode |
| `undo` | Remove Rust, restore Go, revert shell configs |
| `offline` | Enable offline mode — cargo won't download anything |
| `online` | Disable offline mode — cargo can fetch new deps |
| `status` | Show platform, versions, cache size, network mode |
| `help` | Show usage info |

## Shell Aliases (added to `.bashrc` and `.zshrc`)

| Alias | Expands to |
|---|---|
| `co` | `cargo` |
| `cob` | `cargo build` |
| `cor` | `cargo run` |
| `cot` | `cargo test` |
| `coc` | `cargo check` |
| `cof` | `cargo fmt` |
| `col` | `cargo clippy` |
| `cargo-off` | Enable offline mode |
| `cargo-on` | Disable offline mode |

## Default Crates

The script scaffolds a project with these dependencies:

- **rand** 0.9 — random number generation
- **regex** 1 — regular expressions
- **serde** 1 + **serde_json** 1 — serialization/deserialization
- **reqwest** 0.12 (json, blocking) — HTTP client
- **chrono** 0.4 (serde) — date/time handling
- **clap** 4 (derive) — CLI argument parsing

Edit the `CRATES` array at the top of the script to change them.

## How It Works

### setup
1. Removes the `golang` package (via apt/brew/pacman/pkg)
2. Installs Rust via the platform's native package manager (preferred) or rustup fallback
3. Creates `~/rust-project` with a working example using all default crates
4. Strips Go paths from `.bashrc` and `.zshrc`, adds `~/.cargo/bin`
5. Injects aliases into both shell configs (wrapped in markers for easy removal)
6. Cleans `.crate` tarballs from the cargo cache to save disk space

### undo
1. Re-installs Go via the platform package manager
2. Removes Rust
3. Strips the injected alias block from shell configs
4. Deletes `~/rust-project`

### offline / online
Toggles `CARGO_NET_OFFLINE` in the current shell session. When offline, cargo uses only the crates already cached in `~/.cargo/registry/` — no network calls at all.

## Platform Support

| Platform | Rust install | Go remove | Go restore |
|---|---|---|---|
| Termux (Android) | `pkg install rust` | `pkg remove golang` | `pkg install golang` |
| Linux (apt) | `apt install rustc cargo` | `apt remove golang` | `apt install golang` |
| Linux (dnf) | `dnf install rust cargo` | `dnf remove golang` | `dnf install golang` |
| Linux (pacman) | `pacman -S rust cargo` | `pacman -Rns golang` | `pacman -S go` |
| macOS | rustup (minimal) | `brew uninstall go` | `brew install go` |

## Metered Data Note

On a limited connection, run `setup-offline` once to download everything, then use `cargo-off`/`cargo-on` to control when cargo is allowed to reach the network. The cargo cache (`~/.cargo/registry/`) is reused across all projects — you only pay the data cost once per crate version.
