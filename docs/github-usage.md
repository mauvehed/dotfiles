# GitHub Usage

This document provides guidance on interacting with GitHub, primarily focusing on the GitHub CLI tool (`gh`) and general best practices.

## Overview

GitHub is a platform for version control and collaboration using Git. The GitHub CLI (`gh`) brings GitHub to your terminal, allowing you to manage repositories, pull requests, issues, and more without leaving the command line.

## GitHub CLI (`gh`)

The GitHub CLI is the preferred way to interact with GitHub programmatically and from the terminal for many tasks.

### Installation

The GitHub CLI is typically installed via Homebrew if specified in your `chezmoi` configurations:
```sh
brew install gh
```
Refer to the [official installation guide](https://github.com/cli/cli#installation) for other methods.

### Authentication

After installation, you need to authenticate `gh` with your GitHub account:
```sh
gh auth login
```
Follow the prompts. Using `HTTPS` and authenticating with web browser is often the easiest method.

### Common `gh` Commands

*   **Repository Commands (`gh repo ...`)**
    *   Clone a repository:
        ```sh
        gh repo clone <owner>/<repository_name>
        # Example: gh repo clone cli/cli
        ```
    *   Create a new repository:
        ```sh
        gh repo create <repository_name> [options]
        # Example: gh repo create my-new-project --public --source=.
        ```
    *   View a repository in the browser:
        ```sh
        gh repo view --web
        ```

*   **Pull Request Commands (`gh pr ...`)**
    *   List pull requests:
        ```sh
        gh pr list
        ```
    *   View a specific pull request:
        ```sh
        gh pr view <pr_number_or_branch_name>
        # View in browser: gh pr view <pr_number_or_branch_name> --web
        ```
    *   Checkout a pull request locally:
        ```sh
        gh pr checkout <pr_number_or_branch_name>
        ```
    *   Create a pull request:
        ```sh
        gh pr create [options]
        # Example (prompts for title, body, base branch, etc.):
        # gh pr create
        # Example (with details):
        # gh pr create --title "My Awesome Feature" --body "Details about the feature." --base main
        ```
    *   Diff a pull request:
        ```sh
        gh pr diff <pr_number_or_branch_name>
        ```

*   **Issue Commands (`gh issue ...`)**
    *   List issues:
        ```sh
        gh issue list
        ```
    *   View an issue:
        ```sh
        gh issue view <issue_number>
        # View in browser: gh issue view <issue_number> --web
        ```
    *   Create an issue:
        ```sh
        gh issue create --title "My Issue Title" --body "Issue details."
        ```

*   **Alias Management (`gh alias ...`)**
    *   `gh` supports creating aliases for complex commands. Example:
        ```sh
        gh alias set myprs "pr list --author @me"
        gh myprs # Runs the aliased command
        ```

## Git Configuration for GitHub

Ensure your local Git configuration (see `docs/git-usage.md`) is set up correctly with your GitHub username and email, especially if you contribute to multiple repositories or use different identities.

SSH keys are recommended for `git push/pull` operations with GitHub for better security and convenience. Refer to GitHub's documentation on [generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [adding it to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

## Resources

*   **GitHub CLI Official Documentation**: [https://cli.github.com/manual/](https://cli.github.com/manual/)
*   **GitHub CLI GitHub Repository**: [https://github.com/cli/cli](https://github.com/cli/cli)
*   **GitHub Help Documentation**: [https://docs.github.com/](https://docs.github.com/)
*   **GitHub SSH Key Setup**: [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

This document provides a basic overview. The GitHub CLI is very powerful; explore its manual for more commands and options.
