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

# ── gum (interactive picker) ──────────────────────────────────────────────────
command -v gum &>/dev/null || brew install gum

# ── Package registry ──────────────────────────────────────────────────────────
typeset -A PKG_TYPE=(
  [git]=cli             [gh]=cli              [ffmpeg]=cli
  [rclone]=cli          [tesseract]=cli
  [docker]=cask         [utm]=cask            [obs]=cask
  [visual-studio-code]=cask                   [microsoft-office]=cask
  [localsend]=cask          [obsidian]=cask
  [nvm]=special         [git-config]=special  [gh-auth]=special
)

# ── Selection ─────────────────────────────────────────────────────────────────
selected=("${(@f)$(printf '%s\n' ${(k)PKG_TYPE} | sort | \
  gum choose --no-limit --header 'Select packages to install (space=toggle, enter=confirm):' || true)}")

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected. Homebrew is ready; run again to install packages."
  exit 0
fi

# ── Handlers for special items ────────────────────────────────────────────────
install_nvm() {
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
}

install_git_config() {
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
}

install_gh_auth() {
  gh auth status &>/dev/null && echo "gh already authenticated. Skipping." || gh auth login
}

# ── Install loop ──────────────────────────────────────────────────────────────
for item in $selected; do
  case $PKG_TYPE[$item] in
    cli)     command -v $item &>/dev/null && echo "$item already installed. Skipping." || brew install $item ;;
    cask)    brew list --cask $item &>/dev/null && echo "$item already installed. Skipping." || brew install --cask $item ;;
    special) install_${item//-/_} ;;
  esac
done
