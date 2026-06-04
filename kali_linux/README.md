# kali linux setup

Interactive base setup script for Kali Linux. Works on both `amd64` and `arm64`. Installs gum for the interactive picker, then lets you choose packages.

## Run

```bash
curl -fsSL https://raw.githubusercontent.com/YensZAF/dotfiles/main/kali_linux/setup.sh | bash
```

Or with sudo if not running as root:

```bash
curl -fsSL https://raw.githubusercontent.com/YensZAF/dotfiles/main/kali_linux/setup.sh | sudo bash
```

## Packages

| Package | Description |
|---|---|
| `tmux` | terminal multiplexer |
| `neovim` | text editor |
| `fzf` | fuzzy finder |
| `ripgrep` | fast recursive grep |
| `jq` | JSON processor |
| `bat` | syntax-highlighted cat |
| `eza` | modern ls replacement |
| `gh` | GitHub CLI |
| `docker.io` | container runtime |
| `pipx` | isolated Python tool installer |
| `nvm` | Node version manager + LTS (special) |
| `git-config` | git user name/email setup (special) |
| `gh-auth` | GitHub auth setup (special) |

> `git` is pre-installed on Kali — omitted.

## Notes

- Script auto-detects root vs non-root; uses `sudo` only when needed
- Adds [charm.sh](https://charm.sh) apt repo to install `gum`
- Safe to re-run — skips already-installed packages
