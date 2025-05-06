# Enhanced Command-Line Interface (CLI) Usage

This document details configurations and tools aimed at creating a powerful, consistent, and user-friendly command-line interface (CLI) experience, primarily within a Zsh environment managed by `chezmoi`.

## Overview

A productive CLI environment goes beyond just the shell and prompt. It involves using enhanced versions of standard utilities, organizing shell configurations logically, and leveraging tools that streamline common tasks.

## Striving for Consistency (GNU Coreutils on macOS)

To achieve a more GNU/Linux-like CLI experience on macOS, GNU core utilities are often installed. These provide versions of common commands (`ls`, `cp`, `mv`, `date`, `cat`, etc.) with features and options consistent with their Linux counterparts.

*   **Installation (macOS with Homebrew)**:
    ```sh
    brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt grep
    ```
    (You might have a more specific list in your `Brewfile`.)
*   **Usage**: These GNU versions are typically prefixed with `g` (e.g., `gls`, `gcat`, `gdate`) to avoid conflicts with the native macOS utilities.
*   **PATH Configuration**: To use these GNU versions by their standard names (e.g., `ls` instead of `gls`), you would add their directory (e.g., `$(brew --prefix coreutils)/libexec/gnubin`) to the beginning of your `$PATH`.
    *   This is often handled in a dedicated `.path` file or directly in your `.zshrc` / `.zshenv`, managed by `chezmoi`.

## Shell Configuration Files

To keep the main shell configuration file (e.g., `~/.zshrc`) clean and organized, specific aspects of the shell setup are often broken out into separate files, sourced by the main config. These are managed by `chezmoi`.

*   **`~/.path` (or similar)**: Manages the `$PATH` environment variable. It defines the order in which directories are searched for executables. Example content:
    ```sh
    # Example .path structure
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH" # Homebrew
    # Add GNU coreutils if preferred
    # export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
    ```

*   **`~/.exports` (or similar)**: Sets other essential environment variables (e.g., `EDITOR`, `LANG`, `PAGER`, custom variables for tools).
    ```sh
    # Example .exports
    export EDITOR='vim'
    export LANG='en_US.UTF-8'
    export PAGER='less'
    ```

*   **`~/.functions` (or similar)**: Defines custom shell functions to automate common tasks or create complex commands.
    ```sh
    # Example function in .functions
    # mkcd() {
    #   mkdir -p "$1" && cd "$1"
    # }
    ```

*   **`~/.aliases` (or similar)**: Contains command aliases for frequently used commands or commands with common options.
    ```sh
    # Example .aliases
    # alias ll='ls -alhF'
    # alias update='sudo apt update && sudo apt upgrade -y' # Linux example
    # alias brewup='brew update && brew upgrade && brew cleanup' # macOS example
    ```

These files are typically sourced from `~/.zshrc` in a specific order.

## Essential CLI Enhancement Tools

These tools replace or augment standard CLI utilities for a better experience. They are usually installed via package managers (Homebrew, apt, etc.) and managed by `chezmoi`.

*   **`exa`** or **`lsd`**: Modern replacements for `ls` with more colors, icons, and features.
    *   [exa](https://the.exa.website/), [lsd](https://github.com/Peltoche/lsd)
*   **`bat`**: A `cat` clone with syntax highlighting and Git integration.
    *   [bat](https://github.com/sharkdp/bat)
*   **`fd`**: A simple, fast, and user-friendly alternative to `find`.
    *   [fd](https://github.com/sharkdp/fd)
*   **`ripgrep` (`rg`)**: A line-oriented search tool that recursively searches the current directory for a regex pattern (very fast alternative to `grep`).
    *   [ripgrep](https://github.com/BurntSushi/ripgrep)
*   **`fzf`**: A command-line fuzzy finder for history, files, processes, etc. Often integrated with shell keybindings (`Ctrl+R`, `Ctrl+T`).
    *   [fzf](https://github.com/junegunn/fzf)
*   **`zoxide`**: A smarter `cd` command that learns your habits.
    *   [zoxide](https://github.com/ajeetdsouza/zoxide)
*   **`jq`**: A lightweight and flexible command-line JSON processor.
    *   [jq](https://stedolan.github.io/jq/)
*   **`yq`**: A command-line YAML, JSON, and XML processor (similar to `jq` but for more formats).
    *   [yq (Python version)](https://github.com/kislyuk/yq) or [yq (Go version)](https://github.com/mikefarah/yq)
*   **`tldr`**: Collaborative cheatsheets for console commands. Provides simplified man pages.
    *   [tldr-pages](https://tldr.sh/)
*   **`navi`** or **`cheat`**: Interactive command-line cheatsheet tools.
    *   [navi](https://github.com/denisidoro/navi), [cheat](https://github.com/cheat/cheat)
*   **`procs`**: A modern replacement for `ps` written in Rust.
    *   [procs](https://github.com/dalance/procs)
*   **`httpie`** or **`curlie`**: User-friendly CLI HTTP clients, alternatives to `curl`.
    *   [HTTPie](https://httpie.io/), [curlie](https://github.com/rs/curlie)

## General Tips

*   **Keybindings**: Customize Zsh keybindings (often in `.zshrc` or a dedicated file) for frequently used actions or fzf integrations.
*   **Dotfiles Management**: Use `chezmoi edit <filename>` to easily edit any of these configuration files.

## Resources

*   **GNU Coreutils**: [https://www.gnu.org/software/coreutils/](https://www.gnu.org/software/coreutils/)
*   Links to individual tools are provided in the list above.
*   **Awesome Shell**: [https://github.com/alebcay/awesome-shell](https://github.com/alebcay/awesome-shell) (A curated list of awesome command-line frameworks, toolkits, guides, and gizmos)
*   **Awesome CLI Apps**: [https://github.com/agarrharr/awesome-cli-apps](https://github.com/agarrharr/awesome-cli-apps)

This setup aims to make your command-line interactions more efficient and enjoyable. Explore the tools and customize them to fit your workflow.
