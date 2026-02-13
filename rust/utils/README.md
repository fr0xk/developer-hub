# Rust Utils

Core Rust utilities for system management and testing.

## Contents

- `governor.rs`: System resource/governor controller.
- `news.rs`: Rust-based news headline fetcher.

## Building & Usage

### Standalone Utilities
Scripts like `news.rs` and `governor.rs` can be compiled directly:
```bash
rustc rust/utils/news.rs -o news
./news
```
*Note: `governor.rs` requires `termux-api` packages to be installed.*
---
*Generated automatically by Developer Hub Doc-Manager*
