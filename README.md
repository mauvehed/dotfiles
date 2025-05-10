[![gitleaks](https://github.com/mauvehed/dotfiles/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/mauvehed/dotfiles/actions/workflows/gitleaks.yml)

# dotfiles & config management

My collection of my dotfiles used across multiple systems and managed by [chezmoi](https://www.github.com/twpayne/chezmoi).

## Core Prerequisite

To get started, you primarily need a shell environment with `curl` or `wget` to download and execute the `chezmoi` installation script.

## Quick Start

The following command will download and install `chezmoi` (if not already present), initialize it with this dotfiles repository, and apply the configuration. This process will also install and configure other necessary tools such as Homebrew, Zsh, oh-my-zsh, oh-my-posh, and the 1Password CLI.

```sh
  sh -c "$(curl -fsSL get.chezmoi.io)" -- init --apply mauvehed
```
### Edit config for machine type

After the first run of the install script, we'll need to manually edit the chezmoi config in order to set the machine type. This will enable to full package installation.

```sh
  chezmoi edit-config
```

Set `personal = true` or `work = true` depending on the needs. 

Once this is done, re-run chezmoi to force the rest of the install.

```sh
  chezmoi --force apply
```

### 1Password Integration

Personal secrets are stored in [1Password](https://1password.com). The `chezmoi` setup will install the [1Password CLI](https://developer.1password.com/docs/cli/).

1.  **After the initial `chezmoi apply` completes**, you must sign in to the 1Password CLI:
    ```sh
    eval $(op signin)
    ```
2.  **Re-apply `chezmoi` (if needed)**: If the initial `chezmoi apply` could not fully provision all configurations due to 1Password not being authenticated, run the apply command again after signing in:
    ```sh
    chezmoi apply
    ```

## Tools Managed by These Dotfiles

These dotfiles, through `chezmoi`, will install and manage the following tools and configurations on your system:

| Name                | Description                                       | Managed |
| ------------------- | ------------------------------------------------- | -------- |
| Terminal            | [iTerm2](https://iterm2.com) (macOS)              | Optional |
| Package manager     | [Homebrew](https://brew.sh/)                      | Yes      |
| Shell               | [Zsh](https://www.zsh.org/)                       | Yes      |
| Shell Framework     | [oh-my-zsh](https://ohmyzsh.org/)                 | Yes      |
| Shell Prompt Customizer | [oh-my-posh](https://ohmyposh.dev)              | Yes      |
| Dotfiles manager    | [chezmoi](https://chezmoi.io/)                    | Yes      |
| Password Manager CLI| [1Password CLI](https://www.1password.com/)       | Yes      |

## Command Reference

To add new files to chezmoi control:

```sh
chezmoi add <file>
```

To edit a file under chezmoi control:

```sh
chezmoi edit <file>
```

To preview changes before applying:

```sh
chezmoi diff
```

To apply changes from `.local/share/chezmoi/` to ~/ use:

```sh
chezmoi apply
```

To both `git pull` and `chezmoi apply` use `update`

```sh
chezmoi update
```

To force a refresh the downloaded archives (from .`chezmoiexternal.toml`), use the --refresh-externals (-R) flag to chezmoi apply:

```sh
chezmoi -R apply
```

To test chezmoi template files (.tmpl):
```sh
chezmoi execute-template < dot_gitconfig.tmpl
```

## Chezmoi and Git

To execute git commands within the chezmoi source director you can append them to the *chezmoi* command

Git pull:

```sh
chezmoi git pull
```

Git push:

```sh
chezmoi git push
```

Git status:

```sh
chezmoi git status
```

## Resources

* [Repo Docs/](docs/)
* [Install](https://www.chezmoi.io/install/)
* [Quick Start](https://www.chezmoi.io/quick-start/#using-chezmoi-across-multiple-machines)
* [Setup](https://www.chezmoi.io/user-guide/setup/)
* [Chezmoi Github](https://github.com/twpayne/chezmoi)
* [Chezmoi Web](https://chezmoi.io)
