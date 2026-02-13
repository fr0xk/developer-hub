# Offline Development Handbook

Pragmatic, suckless-friendly templates for Rust and Python. Designed for zero-internet environments.

<!-- no-auto -->

## Directory Structure

*   `python/`: Pure standard library patterns + a boilerplate for new tools.
*   `rust/`: A vendored Cargo project with common dependencies (clap, tokio, serde).

## Usage

### Python

```bash
cd python
# Example: if you have a boilerplate.py in python/
# ./boilerplate.py --help
```
Explore `examples/` for syntax and logical flows (IO, logic, concurrency).

### Rust

From the project root:
```bash
cargo run --manifest-path rust/offline-handbook/Cargo.toml -- <command>
```

Available commands:
- `basics`
- `system`
- `async`
- `json`

## Installation

```bash
cargo build --manifest-path rust/offline-handbook/Cargo.toml --release
cp rust/offline-handbook/target/release/handbook ~/.local/bin/
```

## Why this structure?

1.  **Pragmatic**: Focuses on the 20% of code that does 80% of the work.
2.  **Offline**: Rust dependencies are fully vendored in the `vendor/` directory.
3.  **Suckless**: Minimalist logic, no fluff, easy to read and grep.
