#!/usr/bin/env zsh
set -e

# ── Dotfiles symlinks ────────────────────────────────────────────────────────
DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  echo "Backed up existing ~/.zshrc to ~/.zshrc.bak"
fi
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
if [[ ! -f "$HOME/.zshrc_secrets" ]]; then
  cp "$DOTFILES_DIR/zshrc_secrets.example" "$HOME/.zshrc_secrets"
  chmod 600 "$HOME/.zshrc_secrets"
  echo "Created ~/.zshrc_secrets — fill in real API keys there (not tracked in git)."
fi

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
  [rclone]=cli          [tesseract]=cli       [go]=cli
  [fzf]=cli             [sevenzip]=cli
  [docker]=cask         [utm]=cask            [obs]=cask
  [visual-studio-code]=cask                   [microsoft-office]=cask
  [localsend]=cask          [dbeaver-community]=cask  [trezor-suite]=cask
  [keepassxc]=cask          [balenaetcher]=cask
  [nvm]=special         [git-config]=special  [gh-auth]=special
  [obsidian]=special
)

typeset -A PKG_DESC=(
  [git]="version control"          [gh]="GitHub CLI"              [ffmpeg]="media converter"
  [rclone]="cloud sync CLI"        [tesseract]="OCR engine"        [go]="Go language toolchain"
  [fzf]="fuzzy finder"             [sevenzip]="7-Zip archive tool"
  [docker]="container platform"    [utm]="macOS VM manager"        [obs]="screen recorder"
  [visual-studio-code]="code editor"   [microsoft-office]="MS Office suite"
  [localsend]="LAN file sharing"   [dbeaver-community]="DB GUI client"  [trezor-suite]="Trezor hardware wallet"
  [keepassxc]="password manager"  [balenaetcher]="USB/SD image flasher"
  [nvm]="Node version manager"     [git-config]="git user config"  [gh-auth]="GitHub auth setup"
  [obsidian]="markdown notes"
)

# ── Selection ─────────────────────────────────────────────────────────────────
all_items=(${(f)"$(printf '%s\n' ${(k)PKG_TYPE} | sort)"})

display=()
for item in $all_items; do
  display+=("$(printf '%-22s  %s' $item "${PKG_DESC[$item]:-}")")
done

raw=(${(@f)$(printf '%s\n' "${display[@]}" | \
  gum choose --no-limit \
    --header "Select packages  (space=toggle  enter=confirm)" \
  || true)})

selected=()
for c in "${raw[@]}"; do
  name="${c%%  *}"
  [[ -n "${PKG_TYPE[$name]}" ]] && selected+=($name)
done

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

install_obsidian() {
  if brew list --cask obsidian &>/dev/null; then
    echo "obsidian already installed. Skipping."
  else
    brew install --cask obsidian
  fi

  gum confirm "Add Obsidian notes repos?" || return

  mkdir -p "$HOME/Notes"

  while true; do
    repo_url=$(gum input --placeholder "GitHub repo URL")
    [[ -z "$repo_url" ]] && break

    repo_name="${repo_url##*/}"
    repo_name="${repo_name%.git}"
    target="$HOME/Notes/$repo_name"

    if [[ -d "$target" ]]; then
      echo "$target already exists. Skipping clone."
    else
      git clone "$repo_url" "$target"
    fi

    gum confirm "Add another notes repo?" || break
  done
}

# ── Install loop ──────────────────────────────────────────────────────────────
for item in $selected; do
  case $PKG_TYPE[$item] in
    cli)     command -v $item &>/dev/null && echo "$item already installed. Skipping." || brew install $item ;;
    cask)    brew list --cask $item &>/dev/null && echo "$item already installed. Skipping." || brew install --cask $item ;;
    special) install_${item//-/_} ;;
  esac
done
