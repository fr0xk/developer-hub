# Contributing to Developer Hub

Thank you for considering contributing to this repository!

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
4. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
5. **Push to the branch** (`git push origin feature/AmazingFeature`)
6. **Open a Pull Request**

## Code Style

- Keep README files minimal (≤50 words)
- Use consistent naming conventions
- Maintain clean directory structure
- Empty directories are automatically cleaned by pre-commit hook

## Using GitHub CLI

This repository is optimized for `gh`:

```bash
# View repository
gh repo view

# Create pull requests
gh pr create

# Manage issues
gh issue create

# Run CI checks
gh run list
```

## Pre-commit Hook

The repository includes a pre-commit hook that automatically:
- Deletes empty directories
- Ensures clean repository structure
- Runs before every commit

## License

By contributing, you agree that your contributions will be licensed under the existing license of this repository.