# macbook setup

Interactive setup script for macOS. Installs Homebrew, then lets you pick packages via a terminal UI.

## Run

```bash
curl -fsSL https://raw.githubusercontent.com/YensZAF/dotfiles/main/macbook/setup.sh | zsh
```

## Packages

| Package | Type | Description |
|---|---|---|
| `git` | CLI | version control |
| `gh` | CLI | GitHub CLI |
| `ffmpeg` | CLI | media converter |
| `rclone` | CLI | cloud sync CLI |
| `tesseract` | CLI | OCR engine |
| `go` | CLI | Go language toolchain |
| `fzf` | CLI | fuzzy finder |
| `docker` | Cask | container platform |
| `utm` | Cask | macOS VM manager |
| `obs` | Cask | screen recorder |
| `visual-studio-code` | Cask | code editor |
| `microsoft-office` | Cask | MS Office suite |
| `localsend` | Cask | LAN file sharing |
| `dbeaver-community` | Cask | DB GUI client |
| `nvm` | Special | Node version manager + LTS |
| `git-config` | Special | git user name/email setup |
| `gh-auth` | Special | GitHub auth setup |
| `obsidian` | Special | markdown notes + repo clone |

> Requires macOS with zsh (default since Catalina).

## Tools

Standalone scripts in [`tools/`](tools/) — run independently, no setup required.

### smb_sync.sh

Syncs a folder from an SMB share to local disk via `rsync`. Auto-resumes on disconnect.

**Requires:** share mounted in Finder at `/Volumes/<YOUR_SHARE>`
(`Finder → Go → Connect to Server → smb://<YOUR_IP>/<YOUR_SHARE>`)

```bash
bash tools/smb_sync.sh
```

- Navigates SMB share folder tree interactively
- Select target folder, then press `s` to sync
- Syncs to current working directory
- Retries every 30s on failure or share disconnect
- Logs progress to `sync_progress.log`
