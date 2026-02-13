# Rapid Deployment Environment

This directory contains scripts to quickly set up a development environment on a new machine (Termux or Linux).

## Included Files

- `deploy_env.py`: The main deployment script.
- `dotmanager.py`: A standalone dotfile manager used by `deploy_env.py`.
- `requirements.txt`: Python dependencies for the AI workspace.

## Setup & Restoration

To restore your environment on a new machine:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/fr0xk/personalDotfiles.git ~/personalDotfiles
   cd ~/personalDotfiles/deploy_env
   ```

2. **Run the deployment script:**
   You can run the script to install everything at once:
   ```bash
   python3 deploy_env.py --all
   ```

   Or choose specific components:
   - `--system`: Install system packages (git, node, python, go, etc.)
   - `--dotfiles`: Install dotfiles using `dotmanager.py`
   - `--ai`: Setup AI workspace and Python libraries
   - `--cli`: Install Gemini CLI

3. **Verify the installation:**
   ```bash
   python3 deploy_env.py --verify
   ```

## Dependencies

The script will automatically attempt to install the following:
- **System:** `git`, `gh`, `nodejs`, `python3`, `golang`, `build-essential`, `git-crypt`.
- **Python:** `numpy`, `pandas`, `scipy`, `nltk`, `scikit-learn` (listed in `requirements.txt`).
- **NPM:** `@mmmbuto/gemini-cli-termux`.

## Using git-crypt

If your dotfiles are encrypted with `git-crypt`, you can provide the key during deployment:
```bash
python3 deploy_env.py --dotfiles --key /path/to/your/git-crypt.key
```
