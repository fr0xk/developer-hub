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

### Dependency Tests
`complex_test.rs` is a showcase of external dependencies (Tokio, Serde). To run it, it is recommended to use the `offline-handbook` project or a dedicated Cargo environment.
---
*Generated automatically by Developer Hub Doc-Manager*
