[![gitleaks](https://github.com/mauvehed/dotfiles/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/mauvehed/dotfiles/actions/workflows/gitleaks.yml)

# dotfiles

Personal dotfiles for macOS and Linux, managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

```sh
sh -c "$(curl -fsSL get.chezmoi.io)" -- init --apply mauvehed
```

This downloads chezmoi, clones this repo, and runs the initial apply. On Linux, system packages (build-essential, zsh, Python build dependencies) are installed via apt first, then Homebrew, 1Password CLI, brew packages, and asdf runtimes are installed automatically.

### Set Machine Type

After the first run, edit the chezmoi config to set the machine type:

```sh
chezmoi edit-config
```

Set `personal = true` or `work = true`, then re-apply:

```sh
chezmoi --force apply
```

Known hostnames (e.g. `cypher`, `airblade`, `computah`) are auto-detected and don't require manual config.

### 1Password Integration

Secrets are stored in [1Password](https://1password.com) and fetched via `onepasswordRead` in templates. After the initial apply:

```sh
eval $(op signin)
chezmoi apply
```

## What's Managed

### Shell

| Tool | Purpose |
|---|---|
| [Zsh](https://www.zsh.org/) | Shell |
| [oh-my-zsh](https://ohmyzsh.org/) | Shell framework and plugins |
| [oh-my-posh](https://ohmyposh.dev) | Prompt theme engine |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder with fd integration |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd replacement |
| [eza](https://github.com/eza-community/eza) | Modern ls replacement |
| [bat](https://github.com/sharkdp/bat) | Cat replacement with syntax highlighting |

### Shell Config Load Order

1. `~/.zshenv` - XDG dirs, GPG, asdf env vars
2. `~/.zprofile` - Login shell (minimal)
3. `~/.zshrc` - Homebrew, PATH, oh-my-zsh plugins, oh-my-posh, fzf, zoxide, asdf, 1Password SSH agent, iTerm2 integration, ssh-tmux wrapper, Python venv auto-activation
4. `~/.aliases` - Alias aggregator (sources per-platform alias files)

### Aliases

Aliases are composed from templates in `.chezmoitemplates/`:

- `aliases_all.tmpl` - Cross-platform (docker, fzf, eza, bat, zoxide, tailscale, mosh)
- `aliases_git.tmpl` - Git shortcuts (ga, gb, gco, gd, gl, gp, gst)
- `aliases_macos.tmpl` - macOS-only
- `aliases_linuxos.tmpl` - Linux-only

Aliases use conditional checks to only activate when the target binary is present.

### Dev Tools

| Tool | Purpose |
|---|---|
| [asdf](https://asdf-vm.com/) | Runtime version manager (Node.js, Python, Go) |
| [direnv](https://direnv.net/) | Per-directory environment variables (via Homebrew) |
| [Neovim](https://neovim.io/) | Editor with Lazy plugin manager |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer with Dracula theme |
| [git](https://git-scm.com/) | With diff-so-fancy, SSH signing via 1Password |

### Packages

Homebrew packages are defined in `.chezmoidata/packages.yaml` and installed via `brew bundle`. Packages are organized hierarchically:

- `core` - Installed everywhere
- `personal.core` / `work.core` - Machine-type specific
- `darwin` / `linux` - OS-specific
- `personal.darwin` / `personal.linux` - Machine-type + OS specific

### Managed Configs

- `~/.config/git/config` - Global git config (SSH signing, diff-so-fancy, URL rewrites)
- `~/.config/nvim/` - Neovim with Lazy plugins
- `~/.config/oh-my-posh/themes/` - Custom prompt themes
- `~/.config/iterm2/` - iTerm2 profile and Dracula color scheme
- `~/.config/btop/` - btop with Dracula theme
- `~/.claude/` - Claude Code settings and hooks
- `~/.ssh/` - SSH config (keys from 1Password)
- `~/.tmux.conf` - tmux with TPM and Dracula theme

### Custom Scripts (`~/.local/bin/`)

- `git-update` - Batch-pull all repos under `~/gitwork/*/*/*`
- `git-config` - Set per-repo git user/email for multiple GitHub orgs
- `git-upstream` - Git upstream management
- `brew-update` - Homebrew update wrapper
- `crt.sh` - Certificate transparency lookup
- `randkey` - Random key generator
- `check_uptime.sh` - Warn if uptime exceeds 60 days
- `fzf-git.sh` - fzf git integration helpers

### External Resources

Managed via `.chezmoiexternal.toml.tmpl` with auto-refresh:

- oh-my-zsh + zsh-syntax-highlighting plugin
- MesloLGS Nerd Font files
- fzf shell integrations
- tmux Plugin Manager (TPM)
- git-fuzzy
- Dracula eza color theme

## Security

- Secrets are fetched from 1Password at apply time via `onepasswordRead`
- [gitleaks](https://github.com/gitleaks/gitleaks) runs via pre-commit hook and GitHub Actions
- Git commits are signed with SSH keys via 1Password

## Command Reference

```sh
chezmoi diff                        # Preview changes before applying
chezmoi apply -v                    # Apply changes verbosely
chezmoi -R apply                    # Force refresh external resources
chezmoi edit <file>                 # Edit a managed file
chezmoi add <file>                  # Add a file to chezmoi
chezmoi add --template <file>       # Add as a template
chezmoi execute-template < f.tmpl   # Test template rendering
chezmoi data                        # View all template data
chezmoi update                      # git pull + chezmoi apply
chezmoi git status                  # Run git in chezmoi source dir
```

## Resources

- [Repo Docs](docs/)
- [chezmoi Install](https://www.chezmoi.io/install/)
- [chezmoi Quick Start](https://www.chezmoi.io/quick-start/#using-chezmoi-across-multiple-machines)
- [chezmoi User Guide](https://www.chezmoi.io/user-guide/setup/)
- [chezmoi GitHub](https://github.com/twpayne/chezmoi)
