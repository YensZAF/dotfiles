#!/usr/bin/env zsh
set -e

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed. Skipping."
fi

# ── Packages ──────────────────────────────────────────────────────────────────
command -v git    &>/dev/null && echo "git already installed. Skipping."    || brew install git
command -v gh     &>/dev/null && echo "gh already installed. Skipping."     || brew install gh
command -v ffmpeg &>/dev/null && echo "ffmpeg already installed. Skipping." || brew install ffmpeg
brew list --cask docker &>/dev/null && echo "docker already installed. Skipping." || brew install --cask docker
brew list --cask utm   &>/dev/null && echo "utm already installed. Skipping."   || brew install --cask utm
brew list --cask obs           &>/dev/null && echo "obs already installed. Skipping."           || brew install --cask obs
brew list --cask visual-studio-code &>/dev/null && echo "vscode already installed. Skipping." || brew install --cask visual-studio-code

# ── nvm ───────────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  echo "Installing latest LTS Node..."
  nvm install --lts
else
  echo "nvm already installed. Skipping."
fi

# ── Git global config ─────────────────────────────────────────────────────────
if [[ -z "$(git config --global user.name)" ]]; then
  read "git_name?Git username: "
  git config --global user.name "$git_name"
else
  echo "Git username already set. Skipping."
fi

if [[ -z "$(git config --global user.email)" ]]; then
  read "git_email?Git email: "
  git config --global user.email "$git_email"
else
  echo "Git email already set. Skipping."
fi

# ── GitHub CLI auth ───────────────────────────────────────────────────────────
gh auth status &>/dev/null && echo "gh already authenticated. Skipping." || gh auth login
