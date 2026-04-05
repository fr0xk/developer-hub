#!/usr/bin/env bash
#
# rust-env-setup.sh — Portable Rust environment setup with undo support.
#
# Works on: Linux (glibc/musl), macOS, Termux (Android)
#
# Usage:
#   ./rust-env-setup.sh setup          # Install Rust, add crates, configure shells
#   ./rust-env-setup.sh setup-offline  # Setup + default to offline mode
#   ./rust-env-setup.sh undo           # Remove Rust, restore Go, revert shell configs
#   ./rust-env-setup.sh offline        # Toggle offline mode
#   ./rust-env-setup.sh online         # Toggle online mode
#   ./rust-env-setup.sh status         # Show current environment state
#
# Crates installed by default (editable below):
#   rand, regex, serde (+serde_json), reqwest, chrono
#

set -euo pipefail

# ──────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────

CRATES=(
    "rand=0.9"
    "regex=1"
    "serde=1:derive"
    "serde_json=1"
    "reqwest=0.12,json,blocking"
    "chrono=0.4,serde"
)

SHELL_RC_FILES=("$HOME/.bashrc" "$HOME/.zshrc")

MARKER_START="# >>> rust-env-setup: begin >>>"
MARKER_END="# <<< rust-env-setup: end <<<"

# Build the online/offline block dynamically
build_rust_block() {
    cat << BLOCK
${MARKER_START}
# Rust - offline/metered mode
alias co='cargo'
alias cob='cargo build'
alias cor='cargo run'
alias cot='cargo test'
alias coc='cargo check'
alias cof='cargo fmt'
alias col='cargo clippy'
alias cargo-off='export CARGO_NET_OFFLINE=true'
alias cargo-on='unset CARGO_NET_OFFLINE'
${DEFAULT_OFFLINE}
${MARKER_END}
BLOCK
}

GO_PROFILE_CONTENT='# Go environment configuration for static compilation
# Add this to your ~/.bashrc or ~/.zshrc:

# Set CGO_ENABLED=0 for static compilation by default
export CGO_ENABLED=0

# Alias for building Go programs statically
alias go-static='"'"'CGO_ENABLED=0 go build'"'"'

# Function for building with static linking (Android-specific)
go-static-build() {
    CGO_ENABLED=0 go build -a -installsuffix cgo "$@"
}

# Export GOFLAGS for static compilation
export GOFLAGS="-tags netgo"'

# ──────────────────────────────────────────────
# Detect platform
# ──────────────────────────────────────────────

detect_platform() {

    if [ -f /system/bin/getprop ]; then
        echo "termux"
    elif [ "$(uname -s)" = "Darwin" ]; then
        echo "macos"
    else
        echo "linux"
    fi
}

PLATFORM="$(detect_platform)"
DEFAULT_OFFLINE=""

# ──────────────────────────────────────────────
# Logging helpers
# ──────────────────────────────────────────────

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
ok()    { printf "\033[1;32m[ok]\033[0m    %s\n" "$*"; }
warn()  { printf "\033[1;33m[warn]\033[0m   %s\n" "$*"; }
err()   { printf "\033[1;31m[error]\033[0m  %s\n" "$*" >&2; }

# ──────────────────────────────────────────────
# Shell config helpers
# ──────────────────────────────────────────────

# Remove any previously injected block from a file
remove_block_from_rc() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if grep -qF "$MARKER_START" "$rc_file" 2>/dev/null; then
        sed -i "/$(echo "$MARKER_START" | sed 's/[\/&]/\\&/g')/,/$(echo "$MARKER_END" | sed 's/[\/&]/\\&/g')/d" "$rc_file"
    fi
}

# Remove Go path references from a file
remove_go_from_rc() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    sed -i '/\$HOME\/go\/bin/d' "$rc_file"
    sed -i '/GOPATH/d' "$rc_file"
    sed -i '/GOROOT/d' "$rc_file"
    # Remove cargo bin path if present (we'll re-add it cleanly)
    sed -i '/\$HOME\/\.cargo\/bin/d' "$rc_file"
}

# Inject the rust/online-offline block into a shell rc file
inject_rust_block() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    remove_block_from_rc "$rc_file"

    # Don't duplicate — check if already present
    if grep -q "alias co='cargo'" "$rc_file" 2>/dev/null; then
        return 0
    fi

    echo "" >> "$rc_file"
    build_rust_block >> "$rc_file"
}

# Add $HOME/.cargo/bin to PATH in a shell rc file
add_cargo_to_path() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    # Only add if not already there
    if grep -q '\$HOME/\.cargo/bin' "$rc_file" 2>/dev/null; then
        return 0
    fi

    # Try to append to existing PATH export
    if grep -qE '^\s*export\s+PATH=' "$rc_file" 2>/dev/null; then
        # Find the last export PATH= line and append .cargo/bin
        local line
        line=$(grep -nE '^\s*export\s+PATH=' "$rc_file" | tail -1 | cut -d: -f1)
        if [ -n "$line" ]; then
            sed -i "${line}s|\$HOME/\.local/bin:\$HOME/bin:\(.*\)|\$HOME/.local/bin:\$HOME/bin:\$HOME/.cargo/bin:\1|" "$rc_file" 2>/dev/null || \
            sed -i "${line}s|/data/data/com.termux/files/usr/bin|\$HOME/.cargo/bin:/data/data/com.termux/files/usr/bin|" "$rc_file" 2>/dev/null || true
        fi
    fi
}

# ──────────────────────────────────────────────
# Cargo.toml helpers
# ──────────────────────────────────────────────

build_dependencies_section() {
    local content=""
    for crate in "${CRATES[@]}"; do
        local name="${crate%%=*}"
        local rest="${crate#*=}"
        local version="${rest%%,*}"
        local features="${rest#*,}"

        if [ "$features" != "$rest" ] && [ -n "$features" ]; then
            # Build feature string
            local feature_list=""
            IFS=',' read -ra feats <<< "$features"
            for f in "${feats[@]}"; do
                if [ -n "$feature_list" ]; then
                    feature_list="${feature_list}, "
                fi
                feature_list="${feature_list}\"${f}\""
            done

            if [ "$name" = "serde" ]; then
                content+="\nserde = { version = \"${version}\", features = [\"derive\"] }"
            elif [ "$name" = "serde_json" ]; then
                content+="\nserde_json = \"${version}\""
            elif [ "$name" = "chrono" ]; then
                content+="\nchrono = { version = \"${version}\", features = [\"serde\"] }"
            elif [ "$name" = "reqwest" ]; then
                content+="\nreqwest = { version = \"${version}\", features = [\"json\", \"blocking\"] }"
            else
                content+="\n${name} = { version = \"${version}\", features = [${feature_list}] }"
            fi
        else
            content+="\n${name} = \"${version}\""
        fi
    done
    echo -e "$content"
}

create_rust_project() {
    local project_dir="${1:-$HOME/rust-project}"
    info "Creating Rust project at $project_dir"

    mkdir -p "$project_dir/src"

    # Cargo.toml
    cat > "$project_dir/Cargo.toml" << 'TOML'
[package]
name = "rust-project"
version = "0.1.0"
edition = "2021"

[dependencies]
TOML

    # Append dependencies
    build_dependencies_section >> "$project_dir/Cargo.toml"

    # main.rs with usage examples
    cat > "$project_dir/src/main.rs" << 'RS'
use chrono::Utc;
use rand::Rng;
use regex::Regex;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct Data {
    timestamp: String,
    random_value: f64,
    message: String,
}

fn main() {
    // chrono: current timestamp
    let now = Utc::now().to_rfc3339();

    // rand: random number
    let mut rng = rand::rng();
    let random_value: f64 = rng.random_range(0.0..100.0);

    // regex: simple pattern match
    let re = Regex::new(r"hello").unwrap();
    let message = if re.is_match("hello world") {
        "Regex matched 'hello'!"
    } else {
        "No match."
    };

    let data = Data {
        timestamp: now,
        random_value,
        message: message.to_string(),
    };

    // serde: serialize to JSON
    let json = serde_json::to_string_pretty(&data).unwrap();
    println!("{}", json);

    // reqwest example (commented to avoid network call on startup)
    // let resp = reqwest::blocking::get("https://httpbin.org/get").unwrap();
    // println!("Status: {}", resp.status());
}
RS

    ok "Project scaffolded at $project_dir"
    info "Run 'cd $project_dir && cargo build' to fetch deps and compile"
}

# ──────────────────────────────────────────────
# Install Rust
# ──────────────────────────────────────────────

install_rust() {
    if command -v rustc &>/dev/null; then
        ok "Rust already installed: $(rustc --version)"
        return 0
    fi

    info "Installing Rust for $PLATFORM..."

    case "$PLATFORM" in
        termux)
            info "Using Termux package (mirrors existing cache, less data)..."
            pkg install rust -y 2>&1 | tail -5
            ;;
        macos)
            info "Installing via rustup (minimal profile)..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
                | sh -s -- -y --profile minimal --default-toolchain stable
            # Source cargo env
            # shellcheck disable=SC1091
            [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
            ;;
        linux)
            # Check for system package manager first (often cached, less data)
            if command -v apt-get &>/dev/null; then
                info "Trying apt-get for rustc/cargo..."
                sudo apt-get update -qq && sudo apt-get install -y -qq rustc cargo 2>&1 | tail -5
            elif command -v dnf &>/dev/null; then
                info "Trying dnf for rust/cargo..."
                sudo dnf install -y rust cargo 2>&1 | tail -5
            elif command -v pacman &>/dev/null; then
                info "Trying pacman for rust/cargo..."
                sudo pacman -S --noconfirm rust cargo 2>&1 | tail -5
            else
                info "Falling back to rustup..."
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
                    | sh -s -- -y --profile minimal --default-toolchain stable
                # shellcheck disable=SC1091
                [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
            fi
            ;;
    esac

    if command -v rustc &>/dev/null; then
        ok "Rust installed: $(rustc --version)"
        ok "Cargo installed: $(cargo --version)"
    else
        err "Rust installation failed. Please install manually."
        return 1
    fi
}

# ──────────────────────────────────────────────
# Remove Go
# ──────────────────────────────────────────────

remove_go() {
    info "Removing Go..."

    case "$PLATFORM" in
        termux)
            pkg remove golang -y 2>&1 | tail -3
            ;;
        macos)
            if command -v brew &>/dev/null; then
                brew uninstall go 2>/dev/null || true
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                sudo apt-get remove -y golang 2>/dev/null || true
            elif command -v dnf &>/dev/null; then
                sudo dnf remove -y golang 2>/dev/null || true
            elif command -v pacman &>/dev/null; then
                sudo pacman -Rns --noconfirm golang 2>/dev/null || true
            fi
            ;;
    esac

    # Remove .goprofile if present
    [ -f "$HOME/.goprofile" ] && rm -f "$HOME/.goprofile"

    if command -v go &>/dev/null; then
        warn "Go still found — may have been installed outside package manager"
    else
        ok "Go removed"
    fi
}

# ──────────────────────────────────────────────
# Restore Go
# ──────────────────────────────────────────────

restore_go() {
    info "Restoring Go..."

    case "$PLATFORM" in
        termux)
            pkg install golang -y 2>&1 | tail -3
            ;;
        macos)
            if command -v brew &>/dev/null; then
                brew install go 2>&1 | tail -3
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y golang 2>&1 | tail -3
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y golang 2>&1 | tail -3
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm go 2>&1 | tail -3
            fi
            ;;
    esac

    if [ -f "$HOME/.goprofile" ] || grep -q 'GOPATH\|GOROOT' "$HOME/.bashrc" 2>/dev/null; then
        ok "Go environment restored"
    else
        warn "Go installed but env vars not in shell rc — add manually if needed"
    fi

    # Recreate .goprofile
    cat > "$HOME/.goprofile" << 'GEOF'
# Go environment configuration for static compilation
export CGO_ENABLED=0
alias go-static='CGO_ENABLED=0 go build'
go-static-build() {
    CGO_ENABLED=0 go build -a -installsuffix cgo "$@"
}
export GOFLAGS="-tags netgo"
GEOF
    ok ".goprofile restored"
}

# ──────────────────────────────────────────────
# Remove Rust
# ──────────────────────────────────────────────

remove_rust() {
    info "Removing Rust..."

    case "$PLATFORM" in
        termux)
            pkg remove rust -y 2>&1 | tail -3
            ;;
        macos|linux)
            if [ -f "$HOME/.cargo/bin/rustup" ]; then
                rustup self uninstall -y 2>&1 | tail -3
            else
                # Try system package removal
                if command -v apt-get &>/dev/null; then
                    sudo apt-get remove -y rustc cargo 2>/dev/null || true
                elif command -v dnf &>/dev/null; then
                    sudo dnf remove -y rust cargo 2>/dev/null || true
                elif command -v pacman &>/dev/null; then
                    sudo pacman -Rns --noconfirm rust cargo 2>/dev/null || true
                fi
            fi
            ;;
    esac

    if command -v rustc &>/dev/null; then
        warn "Rust still found — may need manual removal of ~/.cargo and ~/.rustup"
    else
        ok "Rust removed"
    fi
}

# ──────────────────────────────────────────────
# Shell config — setup
# ──────────────────────────────────────────────

configure_shells() {
    info "Configuring shell files..."

    for rc in "${SHELL_RC_FILES[@]}"; do
        [ -f "$rc" ] || continue

        info "  Updating $rc"
        remove_go_from_rc "$rc"
        add_cargo_to_path "$rc"
        inject_rust_block "$rc"
    done

    ok "Shell configs updated"
    info "Source them or restart your terminal"
}

# ──────────────────────────────────────────────
# Shell config — undo (restore Go paths, remove Rust)
# ──────────────────────────────────────────────

unconfigure_shells() {
    info "Reverting shell files..."

    for rc in "${SHELL_RC_FILES[@]}"; do
        [ -f "$rc" ] || continue

        remove_block_from_rc "$rc"

        # Remove cargo from PATH
        sed -i '/\$HOME\/\.cargo\/bin/d' "$rc"

        # Restore Go path if .goprofile exists
        if [ -f "$HOME/.goprofile" ] || grep -q 'GOPATH\|GOROOT' "$HOME/.bashrc" 2>/dev/null; then
            if ! grep -q '\$HOME/go/bin' "$rc" 2>/dev/null; then
                # Re-add Go path
                sed -i "s|\$HOME/\.cargo/bin|\$HOME/go/bin|g" "$rc"
            fi
        fi
    done

    ok "Shell configs reverted"
}

# ──────────────────────────────────────────────
# Commands
# ──────────────────────────────────────────────

cmd_setup() {
    remove_go
    install_rust
    create_rust_project "$HOME/rust-project"
    configure_shells
    clean_cache
    info ""
    info "Usage:"
    info "  cargo-off     # Go offline (save data)"
    info "  cargo-on      # Go online (fetch new deps)"
    info "  co build      # Alias for cargo build"
    info "  co run        # Alias for cargo run"
}

cmd_setup_offline() {
    DEFAULT_OFFLINE="export CARGO_NET_OFFLINE=true  # Start in offline mode"
    remove_go
    install_rust
    create_rust_project "$HOME/rust-project"
    configure_shells
    clean_cache
    export CARGO_NET_OFFLINE=true
    info ""
    info "Offline mode active. Use 'cargo-on' to go online."
}

cmd_undo() {
    info "Undoing Rust environment setup..."
    restore_go
    remove_rust
    unconfigure_shells
    [ -d "$HOME/rust-project" ] && rm -rf "$HOME/rust-project"
    ok "Undo complete. Restart your terminal or source your rc files."
}

cmd_offline() {
    export CARGO_NET_OFFLINE=true
    ok "Offline mode ON — cargo will not download anything"
}

cmd_online() {
    unset CARGO_NET_OFFLINE
    ok "Online mode — cargo can fetch new deps"
}

cmd_status() {
    info "Platform:   $PLATFORM"
    info ""

    # Rust
    if command -v rustc &>/dev/null; then
        ok "rustc:  $(rustc --version)"
        ok "cargo:  $(cargo --version)"
    else
        warn "Rust not installed"
    fi

    # Go
    if command -v go &>/dev/null; then
        ok "go:     $(go version 2>/dev/null | head -1)"
    else
        warn "Go not installed"
    fi

    info ""
    info "Cargo cache: $(du -sh "$HOME/.cargo/registry/" 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    info ""

    if [ "${CARGO_NET_OFFLINE:-unset}" = "true" ]; then
        ok "Cargo mode: OFFLINE (no network)"
    else
        warn "Cargo mode: ONLINE (can download)"
    fi

    info ""
    info "Aliases: co, cob, cor, cot, coc, cof, col, cargo-off, cargo-on"

    # Check if project exists
    if [ -d "$HOME/rust-project" ]; then
        info ""
        ok "Rust project: $HOME/rust-project"
    fi
}

clean_cache() {
    info "Cleaning .crate tarballs from cache to save space..."
    if [ -d "$HOME/.cargo/registry/cache" ]; then
        local before
        before=$(du -sh "$HOME/.cargo/registry/cache/" 2>/dev/null | awk '{print $1}')
        rm -rf "$HOME/.cargo/registry/cache/"*
        ok "Cache cleaned: $before -> $(du -sh "$HOME/.cargo/registry/" 2>/dev/null | awk '{print $1}')"
    fi
}

# ──────────────────────────────────────────────
# Main dispatch
# ──────────────────────────────────────────────

usage() {
    cat << 'EOF'
rust-env-setup.sh — Portable Rust setup with undo

Usage:
  ./rust-env-setup.sh setup          Install Rust, remove Go, configure shells
  ./rust-env-setup.sh setup-offline  Same as setup, default to offline mode
  ./rust-env-setup.sh undo           Remove Rust, restore Go, revert shells
  ./rust-env-setup.sh offline        Enable offline mode (no network)
  ./rust-env-setup.sh online         Enable online mode (fetch deps)
  ./rust-env-setup.sh status         Show current environment
  ./rust-env-setup.sh help           Show this message
EOF
}

case "${1:-help}" in
    setup)        cmd_setup ;;
    setup-offline) cmd_setup_offline ;;
    undo)         cmd_undo ;;
    offline)      cmd_offline ;;
    online)       cmd_online ;;
    status)       cmd_status ;;
    help|--help|-h) usage ;;
    *)            err "Unknown command: $1"; usage; exit 1 ;;
esac
