# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/). Contains shell configurations, aliases, and automated setup scripts for macOS and Linux systems. The repository is the chezmoi **source directory** (typically at `~/.local/share/chezmoi`); chezmoi applies it to the **target directory** (`~`).

## Chezmoi Conventions

- **File prefixes**: `dot_` -> `.`, `private_` -> 0600 permissions, `executable_` -> executable bit
- **Templates**: Files ending in `.tmpl` are processed as Go templates before applying
- **Scripts** in `.chezmoiscripts/`:
  - `run_once_before_*` / `run_once_after_*`: Execute once
  - `run_onchange_*`: Re-run when script content changes
  - Dot-prefixed scripts (e.g., `.run_onchange_*`) are **disabled**
- **`.chezmoiremove`**: Lists glob patterns of files chezmoi will actively **delete** from `~` (old configs, stale files)
- **`.chezmoiignore`**: Prevents repo-only files (LICENSE, README, docs/, .pre-commit-config.yaml) from being applied to `~`

## Architecture

### Configuration Data Flow

1. **`.chezmoi.toml.tmpl`** sets machine-type booleans (`personal`, `work`, `headless`, `ephemeral`) plus `osid` and `hostname`. Auto-detects known hostnames (e.g., `cypher`/`airblade` -> personal, `NSANDER-*` -> work). Detects Codespaces/Docker/Multipass as ephemeral.
   - `.chezmoi.os` is always `"linux"` or `"darwin"` — use this for OS-level checks
   - `osid` includes the distro suffix on Linux (e.g., `"linux-ubuntu"`) — use this only for distro-specific logic
2. **`.chezmoidata/packages.yaml`** defines Homebrew packages hierarchically by machine type and OS.
3. **`.chezmoiexternal.toml.tmpl`** manages external git repos (oh-my-zsh, plugins, fonts, fzf helpers, tmux TPM) with 72h refresh intervals.
4. All `.tmpl` files use these variables for conditional inclusion via Go template `{{ if }}` blocks.

### Shell Configuration Layering

Loaded in order by zsh:
1. `dot_zshenv.tmpl` - XDG dirs, GPG, ASDF environment variables
2. `dot_zprofile.tmpl` - Login shell (minimal, Homebrew init moved to zshrc)
3. `dot_zshrc.tmpl` - Main config: Homebrew, PATH, oh-my-zsh plugins, oh-my-posh prompt, fzf, zoxide, asdf, 1Password SSH agent, history (personal-only), iTerm2 integration, ssh-tmux wrapper, Python venv auto-activation
4. `dot_aliases.tmpl` - Alias aggregator

### Alias Composition Pattern

`dot_aliases.tmpl` is a thin aggregator that includes templates from `.chezmoitemplates/`:
- `aliases_all.tmpl` - Cross-platform (docker, fzf, eza, bat, zoxide, tailscale, etc.)
- `aliases_git.tmpl` - Git shortcuts (ga, gb, gco, gd, gl, gp, gst, etc.)
- `aliases_macos.tmpl` - macOS-only (included when `osid == "darwin"`)
- `aliases_linuxos.tmpl` - Linux-only (included when `.chezmoi.os == "linux"`)

Aliases use runtime `command -v` checks to only define aliases when the target binary is available. This is intentional — `lookPath` (chezmoi's template-time check) cannot be used because brew may not be in PATH when chezmoi renders templates on a fresh install.

### Installation Chain

On a fresh `chezmoi init --apply`, scripts run in this order (chezmoi sorts alphabetically):

1. **`run_once_before_00-install-system-packages.sh.tmpl`** - Installs `build-essential`, `zsh`, and Python build dependencies via `apt` on Linux
2. **`run_once_before_install-homebrew.sh.tmpl`** - Installs Homebrew (uses `lookPath "brew"` to skip if already present)
3. **`run_once_before_install-password-manager.sh.tmpl`** - Installs 1Password CLI (via brew on macOS, via apt on Linux)
4. **`run_onchange_install-packages.sh.tmpl`** - Runs `brew bundle` using the `.chezmoitemplates/brew` template, which generates a heredoc from `.chezmoidata/packages.yaml`. Iterates package sections by machine type (`core`, `personal.core`, `personal.darwin`, `work.core`, `darwin`, `linux`) and package kind (`taps`, `brews`, `casks`)
5. **`run_once_after_install-asdf-plugins.sh.tmpl`** - Installs Node.js, Go, and Python via asdf

### Template Convention: `lookPath` vs `command -v`

- **`lookPath`** evaluates at chezmoi template render time. Only use it in install scripts to check if a tool is already installed (e.g., skip Homebrew install if `brew` exists).
- **`command -v`** evaluates at shell runtime. Use this in `dot_zshrc.tmpl` and alias templates for brew-installed binaries, since brew may not be in PATH when chezmoi renders templates on a fresh install.

### Template Helpers

`.chezmoitemplates/utils` provides shell functions used in scripts: `exist()` (command check), `info()`, `user()`, `success()`, `fail()`, `fail_exit()`.

### Custom Scripts

`dot_local/bin/` deploys scripts to `~/.local/bin/`:
- `git-update` - Batch-pulls all repos under `~/gitwork/*/*/*`
- `git-config.tmpl` - Sets per-repo git user/email for multiple GitHub orgs and gitea instances
- `git-upstream` - Git upstream management
- `brew-update` - Homebrew update wrapper
- Various utilities: `crt.sh`, `randkey`, `media_filter.py`, `video_cleaner.py`

### Managed Configs

- `private_dot_config/git/config` - Global git config (SSH signing via 1Password, diff-so-fancy, pull.rebase, URL rewrites like `mvh:` -> github mauvehed, `gh:` -> github)
- `private_dot_config/nvim/` - Neovim configuration
- `private_dot_config/oh-my-posh/` - Prompt themes (separate themes for VSCode terminal vs regular terminal)
- `private_dot_ssh/` - SSH config and authorized_keys (keys from 1Password)
- `dot_claude/` - Claude Code settings managed by chezmoi (settings.json, skills)

## Common Commands

```sh
chezmoi diff                        # Preview changes before applying
chezmoi apply -v                    # Apply changes verbosely
chezmoi apply -R                    # Force refresh external resources
chezmoi edit <file>                 # Edit a managed file
chezmoi add <file>                  # Add a file to chezmoi
chezmoi add --template <file>       # Add as a template
chezmoi execute-template < f.tmpl   # Test template rendering
chezmoi data                        # View all template data
```

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`:
- `check-yaml` and `trailing-whitespace` (pre-commit-hooks v3.2.0)
- `gitleaks` secret scanning (v8.18.2)

A GitHub Actions workflow (`.github/workflows/gitleaks.yml`) also runs gitleaks on push, PR, and daily schedule.

## Secrets

Secrets are managed via 1Password CLI. Templates use `onepasswordRead` to fetch secrets at apply time. The `dot_gitleaks.toml` configures allowed patterns for the secret scanner.

## Documentation

Detailed guides are in `docs/` covering chezmoi, 1Password, terminal setup, Git, Docker, AWS, Kubernetes, Python, Go, Terraform, and VS Code.
