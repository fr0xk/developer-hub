Developer Hub
Personal tools and configs for Android development with Termux.
Includes package backup system and light-themed dotfiles.
Everything is version-controlled and reproducible.

## GitHub CLI Integration

This repository is optimized for `gh` (GitHub CLI):

- ✅ **Authenticated**: `gh auth status` shows active login
- ✅ **SSH configured**: Git operations use SSH protocol
- ✅ **Pre-commit hook**: Automatically cleans empty directories
- ✅ **Custom aliases**: Use `gh repo view`, `gh pr create`, etc.

### Quick gh commands:
```bash
gh repo view          # Open repo in browser
gh pr create          # Create pull requests
gh issue create       # Create issues
gh run list           # View CI runs
```

The `.gh-config.yml` file provides repository-specific settings.