#!/usr/bin/env bash
set -e

# ── Sudo / root handling ───────────────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  if ! command -v sudo &>/dev/null; then
    echo "ERROR: Run as root or install sudo."
    exit 1
  fi
  SUDO="sudo"
fi

# ── Architecture (for future use in special handlers) ─────────────────────────
ARCH=$(dpkg --print-architecture)

# ── System update ─────────────────────────────────────────────────────────────
echo "Updating package lists..."
$SUDO apt-get update -qq

# ── gum (interactive picker) ──────────────────────────────────────────────────
if ! command -v gum &>/dev/null; then
  echo "Installing gum..."
  curl -fsSL https://repo.charm.sh/apt/gpg.key \
    | $SUDO gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
    | $SUDO tee /etc/apt/sources.list.d/charm.list > /dev/null
  $SUDO apt-get update -qq
  $SUDO apt-get install -y gum
else
  echo "gum already installed. Skipping."
fi

# ── Package registry ──────────────────────────────────────────────────────────
declare -A PKG_TYPE=(
  [tmux]=apt            [neovim]=apt          [fzf]=apt
  [ripgrep]=apt         [jq]=apt              [bat]=apt
  [eza]=apt             [gh]=apt              [docker.io]=apt
  [pipx]=apt
  [nvm]=special         [git-config]=special  [gh-auth]=special
)

declare -A PKG_DESC=(
  [tmux]="terminal multiplexer"         [neovim]="text editor"              [fzf]="fuzzy finder"
  [ripgrep]="fast recursive grep"       [jq]="JSON processor"               [bat]="syntax-highlighted cat"
  [eza]="modern ls replacement"         [gh]="GitHub CLI"                   [docker.io]="container runtime"
  [pipx]="isolated Python tool installer"
  [nvm]="Node version manager"          [git-config]="git user config"      [gh-auth]="GitHub auth setup"
)

# ── Selection ─────────────────────────────────────────────────────────────────
mapfile -t all_items < <(printf '%s\n' "${!PKG_TYPE[@]}" | sort)

display=()
for item in "${all_items[@]}"; do
  display+=("$(printf '%-22s  %s' "$item" "${PKG_DESC[$item]:-}")")
done

mapfile -t raw < <(printf '%s\n' "${display[@]}" | \
  gum choose --no-limit \
    --header "Select packages  (space=toggle  enter=confirm)" \
  || true)

selected=()
for c in "${raw[@]}"; do
  name="${c%%  *}"
  [[ -n "${PKG_TYPE[$name]}" ]] && selected+=("$name")
done

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected. Run again to install packages."
  exit 0
fi

# ── Handlers for special items ────────────────────────────────────────────────
install_nvm() {
  if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
    echo "Installing latest LTS Node..."
    nvm install --lts
  else
    echo "nvm already installed. Skipping."
  fi
}

install_git_config() {
  if [[ -z "$(git config --global user.name)" ]]; then
    read -rp "Git username: " git_name
    git config --global user.name "$git_name"
  else
    echo "Git username already set. Skipping."
  fi

  if [[ -z "$(git config --global user.email)" ]]; then
    read -rp "Git email: " git_email
    git config --global user.email "$git_email"
  else
    echo "Git email already set. Skipping."
  fi
}

install_gh_auth() {
  gh auth status &>/dev/null && echo "gh already authenticated. Skipping." || gh auth login
}

# ── Install loop ──────────────────────────────────────────────────────────────
for item in "${selected[@]}"; do
  case ${PKG_TYPE[$item]} in
    apt)
      if dpkg -s "$item" &>/dev/null 2>&1; then
        echo "$item already installed. Skipping."
      else
        $SUDO apt-get install -y "$item"
      fi
      ;;
    special)
      "install_${item//-/_}"
      ;;
  esac
done
