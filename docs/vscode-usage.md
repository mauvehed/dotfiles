# Visual Studio Code Usage

This document provides an overview of using Visual Studio Code (VS Code), including setup, key features, and customization relevant to this dotfiles environment.

## Overview

[Visual Studio Code](https://code.visualstudio.com/) is a lightweight but powerful source code editor that runs on your desktop and is available for Windows, macOS, and Linux. It comes with built-in support for JavaScript, TypeScript, and Node.js and has a rich ecosystem of extensions for other languages and runtimes (such as C++, C#, Java, Python, PHP, Go) and tools (like Docker, Git, and various linters).

## Installation

*   **Download**: Download VS Code from the [official website](https://code.visualstudio.com/download).
*   **Package Managers**:
    *   **macOS (Homebrew)**: `brew install --cask visual-studio-code`
    *   **Linux**: Refer to [VS Code Linux documentation](https://code.visualstudio.com/docs/setup/linux) for instructions for your distribution.

Installation might be managed by `chezmoi` if VS Code is part of your standard toolset defined in your dotfiles.

Launch VS Code and open a terminal within it (`View > Terminal` or ``Ctrl+` ``) to use the `code` command-line interface for opening files and folders.

## Key Features & Customization

### Command Palette
Access all available commands based on your current context by pressing `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS).

### Extensions
VS Code extensions let you add languages, debuggers, and tools to your installation to support your development workflow.
*   **Browse and Install**: Access the Extensions view by clicking on the Extensions icon in the Activity Bar on the side of VS Code or `Ctrl+Shift+X` / `Cmd+Shift+X`.
*   **Recommended Extensions**: VS Code often suggests extensions based on the files you open. You can also find popular extensions for your languages and frameworks in the Marketplace.
*   **Managing Extensions**: You can list your installed extensions from the command line:
    ```sh
    code --list-extensions
    ```
    To install an extension from the command line:
    ```sh
    code --install-extension <extension-id>
    ```
    Your `chezmoi` setup might manage a list of extensions to be installed automatically.

### Settings
Customize VS Code to your liking through its settings.
*   **UI**: Open settings via `File > Preferences > Settings` (`Code > Preferences > Settings` on macOS) or `Ctrl+,` / `Cmd+,`.
*   **JSON**: For more advanced configuration and to manage settings as code, you can edit the `settings.json` file directly. Access it via the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) by typing "Preferences: Open User Settings (JSON)".
*   **Workspace Settings**: You can also define settings specific to a project/workspace by creating a `.vscode/settings.json` file in your project root.
*   Your `chezmoi` setup likely manages your global `settings.json` file.

### Settings Sync
VS Code has built-in Settings Sync, which allows you to share your VS Code configurations—such as settings, keybindings, and installed extensions—across your different machines using a GitHub or Microsoft account.
*   **Enable/Disable**: Turn on Settings Sync from the Manage gear icon at the bottom of the Activity Bar, then "Turn on Settings Sync...".

### Keybindings
Customize keyboard shortcuts in VS Code.
*   **UI**: `File > Preferences > Keyboard Shortcuts` (`Code > Preferences > Keyboard Shortcuts` on macOS) or `Ctrl+K Ctrl+S` / `Cmd+K Cmd+S`.
*   **JSON**: For advanced customization, edit `keybindings.json`. Access it via the Command Palette with "Preferences: Open Keyboard Shortcuts (JSON)".
*   Your `chezmoi` setup might manage your `keybindings.json`.

### Integrated Terminal
VS Code has an integrated terminal (`View > Terminal` or `` Ctrl+` ``) so you can run shell commands directly within the editor.

## GitHub Codespaces

[GitHub Codespaces](https://github.com/features/codespaces) provides cloud-powered development environments. You can use VS Code (desktop or web) to connect to a Codespace, giving you a fully configured development environment in the cloud, often based on a `devcontainer.json` configuration in your repository (see `docs/docker-usage.md` for more on Dev Containers).

### Benefits:
*   **Pre-configured environments**: Start coding immediately with environments tailored for your project.
*   **Access from anywhere**: Develop from any machine with a browser or VS Code.
*   **Consistent setup**: Ensures consistency across team members.

## Resources

*   **Official VS Code Documentation**: [https://code.visualstudio.com/docs](https://code.visualstudio.com/docs)
*   **Introductory Videos**: [https://code.visualstudio.com/docs/getstarted/introvideos](https://code.visualstudio.com/docs/getstarted/introvideos)
*   **VS Code Extension Marketplace**: [https://marketplace.visualstudio.com/vscode](https://marketplace.visualstudio.com/vscode)
*   **Settings Sync Guide**: [https://code.visualstudio.com/docs/editor/settings-sync](https://code.visualstudio.com/docs/editor/settings-sync)
*   **GitHub Codespaces Documentation**: [https://docs.github.com/en/codespaces](https://docs.github.com/en/codespaces)

This document covers the basics. VS Code is highly extensible and configurable; explore the official documentation to tailor it to your workflow.
