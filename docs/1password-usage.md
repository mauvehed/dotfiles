# 1Password Usage

This document outlines how the [1Password CLI](https://developer.1password.com/docs/cli/) is integrated with `chezmoi` for managing secrets and sensitive configuration data in this dotfiles setup.

## Overview

1Password is the primary secrets manager for this dotfiles configuration. `chezmoi` is configured to use the 1Password CLI (`op`) to fetch secrets, which are then injected into configuration files via templates.

## Prerequisites

1.  **1Password Account**: You need an active 1Password account.
2.  **1Password CLI Installed**: The `chezmoi` quick start process (see main `README.md`) handles the installation of the `op` CLI tool.
3.  **Initial Sign-in**: As detailed in the main `README.md`, after the initial `chezmoi apply`, you must sign in to the 1Password CLI:
    ```sh
    eval $(op signin)
    ```
    You may need to run `chezmoi apply` again after this initial sign-in if some secrets were not provisioned.

## Storing and Referencing Secrets with Chezmoi

`chezmoi` utilizes its template functions to interact with the `op` CLI. Secrets are stored in your 1Password vaults, and `chezmoi` templates reference them, typically using the `onepassword` template function or by directly calling `op`.

### General Approach

1.  **Store Secret in 1Password**: Add your secret (e.g., API key, token, password) to your 1Password vault.
    *   Use clear, consistent item names.
    *   For multi-field items, note the field names you want to retrieve.
2.  **Reference in Chezmoi Template**: In your `chezmoi` template file (e.g., `private_dot_config/some_app/config.toml.tmpl`), use a `chezmoi` template function to fetch the secret.

### Example: Storing an API Key

*   **In 1Password**:
    *   Create a "Login" or "API Credential" item named, for example, `My App API Key`.
    *   Store the API key in the `password` field or a custom field.
*   **In `chezmoi` template**:
    ```toml
    # Example: .config/my_app/credentials.tmpl
    # api_key = "{{ (onepasswordRead "op://Personal/My App API Key/password").stdout }}"
    ```
    *(Note: The exact `onepasswordRead` syntax or alternative `op` calls might vary based on your specific `chezmoi` helper functions or direct CLI usage in templates.)*

### Storing GPG Git Signing Key ID

To securely store and retrieve your GPG key ID for Git commit signing:

1.  **In 1Password**:
    *   Create a "Secure Note" or "Login" item, perhaps named `Git Configuration` or `My GPG Key`.
    *   Add a custom field (e.g., named `git_signingkey_id`) and paste your GPG key ID into its value.
2.  **In `chezmoi` template (e.g., `dot_gitconfig.tmpl`):**
    ```gitconfig
    # Example for .gitconfig.tmpl
    [user]
        name = {{ .name | quote }}
        email = {{ .email | quote }}
    #   signingkey = "{{ (onepasswordRead "op://Personal/Git Configuration/git_signingkey_id").stdout }}"
    ```
    *(Adjust the item name and path as per your 1Password setup.)*

## Common `chezmoi` Template Functions for 1Password

*(This section can be expanded with specific examples of `onepassword` functions or custom `op` CLI wrappers you use in your templates.)*

*   `onepassword "item_name"`
*   `onepasswordDetails "item_name"`
*   `onepasswordRead "op_item_path"` (e.g., `op://Vault/ItemName/fieldname`)

Refer to your `chezmoi` configuration and the official `chezmoi` documentation for the exact functions and syntax available and preferred in your setup.

## Troubleshooting

*   **Authentication Issues**: Ensure `eval $(op signin)` has been run and your session is active.
*   **Item Paths**: Double-check the 1Password item names, vault names, and field names used in your templates. The `op item get "Item Name" --fields label="Field Name"` command can be useful for verifying.
*   **Chezmoi Apply**: Remember to run `chezmoi apply` to propagate changes after updating templates or 1Password items. 