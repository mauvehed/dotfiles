# System Usage & OS-Specific Notes

This document outlines system-level configurations, OS-specific notes, and common utilities relevant to this dotfiles setup across different operating systems.

## Overview

These dotfiles aim to provide a consistent experience across macOS, Linux (primarily Ubuntu), and Windows (via WSL). `chezmoi` plays a crucial role in managing OS-specific configurations by using templates and conditional logic based on the operating system.

## General Principles

*   **`chezmoi` for OS Detection**: `chezmoi` templates often use variables like `.chezmoi.os` (e.g., "darwin", "linux", "windows") to apply OS-specific settings or install different packages.
*   **Homebrew/Linuxbrew**: Homebrew (on macOS) and Linuxbrew (on Linux) are heavily utilized for package management. See `Brewfile` or `chezmoi` scripts for lists of managed packages.
*   **Common Utilities**: Many command-line utilities are installed for enhanced productivity. Some common examples that might be included (and configured by these dotfiles) are:
    *   `exa` or `lsd` (modern `ls` replacements)
    *   `bat` (a `cat` clone with syntax highlighting)
    *   `fd` (a simple, fast, and user-friendly alternative to `find`)
    *   `ripgrep` (`rg`) (a line-oriented search tool that recursively searches your current directory for a regex pattern)
    *   `fzf` (a command-line fuzzy finder)
    *   `zoxide` (a smarter `cd` command)
    *   `htop` or `btop` (interactive process viewers)

## macOS Specifics

*   **Package Manager**: [Homebrew](https://brew.sh/) is the primary package manager.
*   **Shell**: Zsh, configured via `oh-my-zsh` and `oh-my-posh` (see `docs/terminal-usage.md`).
*   **Finder Tweaks**: Your `chezmoi` setup might include scripts to apply common Finder settings (e.g., show hidden files, show path bar).
    *   Example commands (often found in `run_once_` scripts):
        ```sh
        # Show hidden files
        # defaults write com.apple.finder AppleShowAllFiles -bool true
        # Show path bar
        # defaults write com.apple.finder ShowPathbar -bool true
        # Restart Finder to apply changes
        # killall Finder
        ```
*   **Keyboard Shortcuts/Remapping**: Tools like Karabiner-Elements might be used for advanced keyboard customization (if included in your setup).
*   **Spotlight**: Useful for launching applications and finding files (`Cmd+Space`).
*   **System Updates**: `sudo softwareupdate -i -a`

## Linux (Ubuntu Focus)

*   **Package Manager**: `apt` is the system package manager. [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux) might also be used for user-space packages.
*   **Shell**: Zsh, configured via `oh-my-zsh` and `oh-my-posh` (see `docs/terminal-usage.md`).
*   **System Updates**:
    ```sh
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y # To remove unused packages
    ```
*   **Firewall**: `ufw` (Uncomplicated Firewall) is commonly used.
    ```sh
    # sudo ufw status
    # sudo ufw enable
    # sudo ufw allow ssh
    ```

## Windows (via WSL - Windows Subsystem for Linux)

*   **WSL Version**: It's recommended to use WSL 2 for better performance and system call compatibility.
*   **Distribution**: Typically Ubuntu is used within WSL, so many Linux notes apply.
*   **Accessing Windows Files**: Windows drives are typically mounted under `/mnt/` (e.g., `/mnt/c`).
*   **Windows Terminal**: Recommended for a better WSL experience.
*   **Interoperability**: You can run Windows executables from WSL and Linux executables from Windows (PowerShell/CMD).
*   **Docker Desktop with WSL Backend**: Often used for Docker development on Windows.

## GitHub Codespaces

GitHub Codespaces typically run a Linux environment (often Ubuntu-based).
*   **Dotfiles Integration**: Your dotfiles can be automatically installed into Codespaces if configured in your GitHub settings.
*   **`devcontainer.json`**: Projects can define specific configurations for Codespaces using a `devcontainer.json` file, which can include features, extensions, and post-create commands.
*   The environment is largely Linux-based, so Linux configurations from your dotfiles will apply.

## Resources

*   **macOS User Guide**: [https://support.apple.com/guide/mac-help/welcome/mac](https://support.apple.com/guide/mac-help/welcome/mac)
*   **Ubuntu Server Guide / Desktop Guide**: [https://ubuntu.com/server/docs](https://ubuntu.com/server/docs), [https://ubuntu.com/desktop/docs](https://ubuntu.com/desktop/docs)
*   **Windows Subsystem for Linux (WSL) Documentation**: [https://docs.microsoft.com/en-us/windows/wsl/](https://docs.microsoft.com/en-us/windows/wsl/)
*   **Chezmoi Documentation (OS specific logic)**: [https://www.chezmoi.io/user-guide/templating/#variables](https://www.chezmoi.io/user-guide/templating/#variables)
*   **Homebrew**: [https://brew.sh/](https://brew.sh/)
*   **Linuxbrew**: [https://docs.brew.sh/Homebrew-on-Linux](https://docs.brew.sh/Homebrew-on-Linux)

This document provides a high-level overview. Specific configurations and scripts are managed by `chezmoi` and can be found within the repository.
