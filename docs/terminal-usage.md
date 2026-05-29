# Terminal Setup and Usage

This document describes the terminal environment setup, including the shell, prompt, terminal emulators, and related tools used in this dotfiles configuration.

## Overview

A customized and efficient terminal setup is crucial for productivity. This setup primarily revolves around Zsh, Oh My Zsh, Powerlevel10k/Oh My Posh for the prompt, and iTerm2 on macOS.

## Terminal Emulator

### iTerm2 (macOS)

[iTerm2](https://iterm2.com/) is a popular replacement for Apple's Terminal on macOS. It offers a wide range of features, including split panes, profiles, triggers, and extensive customization options.

**Configuration Management with `chezmoi`**:

iTerm2 settings are stored in a `.plist` file, typically `~/Library/Preferences/com.googlecode.iterm2.plist`.
Your `chezmoi` setup might manage this file or a human-readable version (e.g., XML) of it.

The commands previously noted for backup/restore can be adapted for `chezmoi`:
1.  **Exporting current iTerm2 settings to XML (for `chezmoi` source directory)**:
    ```sh
    # Ensure the target directory in your chezmoi source exists, e.g., private_dot_config/iterm2/
    TARGET_XML="$HOME/.local/share/chezmoi/private_dot_config/iterm2/com.googlecode.iterm2.plist.xml" # Adjust path as needed
    TEMP_PLIST=$(mktemp)
    defaults export com.googlecode.iterm2 "$TEMP_PLIST"
    plutil -convert xml1 -o "$TARGET_XML" "$TEMP_PLIST"
    rm "$TEMP_PLIST"
    echo "iTerm2 config exported to $TARGET_XML. Run 'chezmoi add private_dot_config/iterm2/com.googlecode.iterm2.plist.xml' if new."
    ```
    Then, format `$TARGET_XML` if desired and `chezmoi add` / `chezmoi apply`.

2.  **Importing settings from `chezmoi` (managed by `chezmoi apply`)**:
    If `chezmoi` manages an XML version, it might use a `run_script_` or template to convert it back to binary plist and import using `defaults import com.googlecode.iterm2 /path/to/your/plist/from/chezmoi` or directly manage the binary plist if `chezmoi`'s templating/symlinking handles it.

*   **Official Website**: [https://iterm2.com/](https://iterm2.com/)

### Other Terminal Emulators (Windows Terminal, Alacritty, etc.)
For Linux and Windows (WSL), other terminal emulators like Windows Terminal, Alacritty, Kitty, etc., can be used. Configuration for these would be managed by `chezmoi` as well, typically by templating their respective configuration files.

## Shell: Zsh (Z Shell)

[Zsh](https://www.zsh.org/) is a powerful shell with numerous features, including improved tab completion, command history, and customization options.

## Zsh Framework: Oh My Zsh

[Oh My Zsh](https://ohmyz.sh/) is an open-source, community-driven framework for managing your Zsh configuration. It comes bundled with thousands of helpful functions, helpers, plugins, and themes.

*   **Installation**: Typically managed by `chezmoi` as part of the initial setup.
*   **Plugins**: Enhance functionality (e.g., `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`). Your `.zshrc` (managed by `chezmoi`) will list enabled plugins.
*   **Themes**: Oh My Zsh offers many themes, but this setup often uses a more specialized prompt theme engine like Powerlevel10k or Oh My Posh.
*   **Official Website**: [https://ohmyz.sh/](https://ohmyz.sh/)
*   **GitHub**: [https://github.com/ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)

## Shell Prompt

A highly customized and informative prompt is key for an efficient workflow.

### Powerlevel10k (p10k)

[Powerlevel10k](https://github.com/romkatv/powerlevel10k) is a theme for Zsh. It emphasizes speed, flexibility, and an out-of-the-box awesome experience. It's known for its configuration wizard that helps you tailor the prompt to your liking.

*   **Installation**: Often installed as a theme for Oh My Zsh.
*   **Configuration**: Run `p10k configure` to go through the setup wizard. The resulting configuration (`~/.p10k.zsh`) is typically managed by `chezmoi`.
*   **Requires**: A Nerd Font or a font patched with Powerline symbols for icons to display correctly.
*   **GitHub**: [https://github.com/romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)

### Oh My Posh

[Oh My Posh](https://ohmyposh.dev/) is a custom prompt engine for any shell that has the ability to adjust the prompt string with a function or variable. It allows for finely tuned, themeable prompts.

*   **Installation**: Typically installed via Homebrew or other package managers.
*   **Configuration**: Defined by a JSON, TOML, or YAML theme file (e.g., `~/.config/omp.json` or similar, path defined in `.zshrc`). This theme file is managed by `chezmoi`.
*   **Requires**: A Nerd Font for icons.
*   **Official Website**: [https://ohmyposh.dev/](https://ohmyposh.dev/)

*(Note: Your setup might use Powerlevel10k directly or use Oh My Posh with a p10k-like theme or another custom theme. Clarify which is primary if necessary in your `.zshrc` or this doc.)*

## Terminal Multiplexer: `tmux` (If Used)

If [tmux](https://github.com/tmux/tmux/wiki) is part of your setup for managing multiple terminal sessions:
*   **Configuration**: `~/.tmux.conf` (managed by `chezmoi`).
*   **Plugin Manager**: [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm) might be used.
*   **Keybindings**: Custom keybindings would be defined in `.tmux.conf`.

## Key Fonts (Nerd Fonts)

For icons and special symbols in prompts (Powerlevel10k, Oh My Posh) and other terminal applications (e.g., `lsd`, `bat`), [Nerd Fonts](https://www.nerdfonts.com/) are commonly used. These are popular programming fonts patched with a high number of glyphs (icons).

*   **Installation**: Download from Nerd Fonts website or install via Homebrew Cask (e.g., `brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font`).
*   Ensure your terminal emulator (iTerm2, etc.) is configured to use a Nerd Font.

## Resources

*   **iTerm2**: [https://iterm2.com/](https://iterm2.com/)
*   **Zsh**: [https://www.zsh.org/](https://www.zsh.org/)
*   **Oh My Zsh**: [https://ohmyz.sh/](https://ohmyz.sh/)
*   **Powerlevel10k**: [https://github.com/romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k)
*   **Oh My Posh**: [https://ohmyposh.dev/](https://ohmyposh.dev/)
*   **Nerd Fonts**: [https://www.nerdfonts.com/](https://www.nerdfonts.com/)
*   **tmux**: [https://github.com/tmux/tmux/wiki](https://github.com/tmux/tmux/wiki)

This document outlines the core components of the terminal setup. Specific configurations are managed by `chezmoi`.
