# Git Usage and Best Practices

This document outlines Git configuration, best practices for commit signing with GPG and 1Password, and useful Git commands relevant to this dotfiles setup.

## Table of Contents

- [Git Usage and Best Practices](#git-usage-and-best-practices)
  - [Table of Contents](#table-of-contents)
  - [Core Git Configuration](#core-git-configuration)
  - [Commit Signing with GPG and 1Password](#commit-signing-with-gpg-and-1password)
    - [1. Generating or Importing Your GPG Key](#1-generating-or-importing-your-gpg-key)
    - [2. Adding Your GPG Key ID to 1Password](#2-adding-your-gpg-key-id-to-1password)
    - [3. Configuring Git to Use the GPG Key (via `chezmoi` and 1Password)](#3-configuring-git-to-use-the-gpg-key-via-chezmoi-and-1password)
    - [4. Adding GPG Public Key to GitHub](#4-adding-gpg-public-key-to-github)
    - [5. GPG Agent Configuration](#5-gpg-agent-configuration)
    - [6. Troubleshooting GPG Signing](#6-troubleshooting-gpg-signing)
  - [GitHub CLI Authentication (`gh auth login`)](#github-cli-authentication-gh-auth-login)
  - [Common Git Workflows and Useful Commands](#common-git-workflows-and-useful-commands)
    - [Basic Workflow](#basic-workflow)
    - [Branching](#branching)
    - [Stashing Changes](#stashing-changes)
    - [Viewing History](#viewing-history)
    - [Squashing Commits](#squashing-commits)
    - [Tags](#tags)
  - [Resources](#resources)

## Core Git Configuration

Key Git settings are managed by `chezmoi` via the `dot_gitconfig.tmpl` template file, which generates `~/.gitconfig`.
This configuration generally promotes trunk-based development and a linear Git history.

Common global settings include:

```ini
# Example from dot_gitconfig.tmpl (values are templated)
[user]
  name = {{ .name | quote }}
  email = {{ .email | quote }}
  signingkey = {{ (onepasswordRead "op://Personal/Git GPG Key/key_id").stdout | trim | quote }} # Fetched from 1Password
[commit]
  gpgsign = true       # Sign all commits by default
[pull]
  rebase = true        # Prefer rebase over merge on pull
[rebase]
  autoStash = true     # Automatically stash changes before rebase
[push]
  default = current    # Push the current branch to a branch of the same name
  followTags = true    # Push tags that point to commits being pushed
[branch]
  autosetupmerge = false # Do not automatically set up merge configurations
  autosetuprebase = always # Always rebase when pulling on new branches
[core]
  autocrlf = input     # Handle line endings correctly
  # ... other settings ...
[remote "origin"]
  prune = true         # Remove remote-tracking branches that no longer exist on the remote
```

*   The specific template is located at: `{{ .chezmoi.sourceDir }}/dot_gitconfig.tmpl`.
*   Refer to the [Git Reference documentation](https://git-scm.com/docs) for details on these settings.

## Commit Signing with GPG and 1Password

Signing Git commits cryptographically verifies the committer's identity. This setup uses GPG for signing, with the GPG key ID managed via 1Password.

### 1. Generating or Importing Your GPG Key

If you don't have a GPG key, generate one:

```sh
gpg --full-gen-key
```
Follow the prompts. An `ECDSA` key with `nistp256` curve is a good modern choice. Ensure you use a strong passphrase and store it securely (e.g., in 1Password).

If you have an existing GPG key, ensure it's in your GPG keyring.

### 2. Adding Your GPG Key ID to 1Password

Once you have a GPG key, get its Key ID:

```sh
gpg --list-secret-keys --keyid-format LONG "Your Name" # Or your email
```
Output will look like:
```
sec   nistp256/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX YYYY-MM-DD [SCA]
      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
uid                 [ultimate] Your Name <your.email@example.com>
ssb   nistp256/YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY YYYY-MM-DD [E]
```
The long Key ID is `XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX` (the 40-character string).

Store this Key ID in 1Password. For example, create a "Secure Note" or "Login" item named "Git GPG Key" and add a field/label (e.g., `key_id`) with your GPG Key ID as the value.

See `docs/1password-usage.md` for more on storing items in 1Password.

### 3. Configuring Git to Use the GPG Key (via `chezmoi` and 1Password)

As shown in the "Core Git Configuration" section, `dot_gitconfig.tmpl` is set up to fetch the `user.signingkey` from 1Password:

```ini
[user]
  signingkey = {{ (onepasswordRead "op://Personal/Git GPG Key/key_id").stdout | trim | quote }}
```
Ensure the 1Password item path (`op://Personal/Git GPG Key/key_id`) in your `dot_gitconfig.tmpl` matches where you stored the key ID in 1Password.
`chezmoi apply` will populate your `~/.gitconfig` with this signing key.

### 4. Adding GPG Public Key to GitHub

To have GitHub show your commits as "Verified":

1.  Export your GPG public key:
    ```sh
    gpg --armor --export XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX # Use your Key ID
    ```
2.  Copy the entire output (starting with `-----BEGIN PGP PUBLIC KEY BLOCK-----`).
3.  Go to [GitHub GPG keys settings](https://github.com/settings/keys) and add the new GPG key.

### 5. GPG Agent Configuration

To avoid entering your GPG passphrase for every commit, configure the `gpg-agent` to cache it. `chezmoi` manages `~/.gnupg/gpg-agent.conf`:

```
# Example content for gpg-agent.conf.tmpl
# Managed by chezmoi

pinentry-program {{ .pinentryProgram | quote }} # Path to pinentry, templated by chezmoi
default-cache-ttl 10800 # Cache passphrase for 3 hours
max-cache-ttl 10800     # Max cache time
```
`chezmoi` templates can determine the correct `pinentry-program` path based on your OS.
After changes, you might need to restart the agent: `gpgconf --kill gpg-agent`.

### 6. Troubleshooting GPG Signing

*   **Error: `gpg failed to sign the data` or `Inappropriate ioctl for device`**:
    Ensure `export GPG_TTY=$(tty)` is in your shell configuration (e.g., `~/.exports` or `~/.zshrc`, managed by `chezmoi`). This allows GPG to prompt for a passphrase in the current terminal.
    ```sh
    # Ensure this line is in a chezmoi-managed shell startup file:
    # export GPG_TTY=$(tty)
    ```
    Restart your shell or source the updated file.
*   **No Pinentry Program Found**: Ensure `pinentry` is installed (e.g., `brew install pinentry-mac` on macOS) and `gpg-agent.conf` points to the correct program.
*   **Secret Key Not Available**: Verify the key ID in `~/.gitconfig` matches a private key in your `gpg --list-secret-keys` output.

## GitHub CLI Authentication (`gh auth login`)

While Git uses SSH or HTTPS (often with a credential helper) for repository access, the GitHub CLI (`gh`) requires its own authentication.

```sh
gh auth login
```
Follow the prompts. Authenticating with a web browser (HTTPS) is often simplest.
Refer to `docs/github-usage.md` for more on using `gh`.

## Common Git Workflows and Useful Commands

### Basic Workflow

```sh
git pull             # Fetch and integrate changes from remote
git add .            # Stage all changes in the current directory
# Or git add <file1> <file2> ... to stage specific files
git commit -S -m "Your descriptive commit message" # Create a signed commit
git push             # Push changes to the remote repository
```

### Branching

*   Create a new branch and switch to it:
    ```sh
    git checkout -b new-feature-branch
    ```
*   Switch to an existing branch:
    ```sh
    git checkout main
    ```
*   Delete a local branch (after merging):
    ```sh
    git branch -d feature-branch # Safe delete (only if merged)
    git branch -D feature-branch # Force delete
    ```
*   Push a new local branch to remote and set up tracking:
    ```sh
    git push -u origin new-feature-branch
    ```

### Stashing Changes

Temporarily save uncommitted changes:

```sh
git stash push -m "WIP: some changes for later"
git stash list
git stash apply stash@{0} # Apply a specific stash
git stash pop           # Apply the latest stash and remove it from the list
git stash drop stash@{0}  # Remove a specific stash
```

### Viewing History

*   Compact log view:
    ```sh
    git log --oneline --graph --decorate --all
    ```
    (Consider creating a Git alias like `git la` for this.)
*   View changes for a specific commit:
    ```sh
    git show <commit_hash>
    ```
*   View changes for a specific file:
    ```sh
    git log -p -- <file_path>
    ```

### Squashing Commits

Combine multiple commits into a single one, often done before merging a feature branch.

*   Interactively rebase onto `main` (or your target branch), squashing commits from your current feature branch:
    ```sh
    # Assuming you are on your feature branch that branched off main
    git rebase -i main
    ```
    In the interactive editor, change `pick` to `s` (squash) or `f` (fixup) for commits you want to merge into the preceding one. Edit commit messages as needed.
*   Force push (with lease) if you've rewritten history on a shared branch (use with caution):
    ```sh
    git push --force-with-lease
    ```

Alternatively, the example from the previous version for squashing all commits on a branch into one based on `main`:
```sh
# git checkout your-feature-branch
# git reset $(git merge-base main $(git branch --show-current))
# git add .
# git commit -S -m "New single commit message for the feature"
# git push --force-with-lease origin your-feature-branch
```

### Tags

Create lightweight or annotated tags for releases:

```sh
git tag v1.0.0                                # Lightweight tag
git tag -a v1.0.1 -m "Version 1.0.1 release"  # Annotated tag (signed if gpgsign=true)
git push origin v1.0.1                        # Push a specific tag
git push --tags                               # Push all tags
```

## Resources

*   **Pro Git Book**: [https://git-scm.com/book/en/v2](https://git-scm.com/book/en/v2) (Excellent, comprehensive guide)
*   **Git Reference Documentation**: [https://git-scm.com/docs](https://git-scm.com/docs)
*   **GitHub GPG Signing Documentation**: [https://docs.github.com/en/authentication/managing-commit-signature-verification](https://docs.github.com/en/authentication/managing-commit-signature-verification)
*   **1Password Documentation**: See `docs/1password-usage.md`
*   **GitHub CLI Documentation**: See `docs/github-usage.md`

This guide covers key Git practices for this dotfiles setup. Consistent use of signed commits and a clean history are encouraged.
