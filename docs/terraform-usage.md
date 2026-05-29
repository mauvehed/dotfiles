# Terraform Usage

This document provides a guide to using Terraform for managing infrastructure as code, including version management with `tfenv`.

## Overview

[Terraform](https://www.terraform.io/) is an open-source infrastructure as code (IaC) software tool that enables you to safely and predictably create, change, and improve infrastructure. It codifies APIs into declarative configuration files.

[tfenv](https://github.com/tfutils/tfenv) is a Terraform version manager, allowing you to easily switch between different versions of Terraform on a per-project basis.

## Installation

### `tfenv` (Terraform Version Manager)

It's recommended to install `tfenv` first to manage your Terraform versions.

**Installation (macOS with Homebrew):**
```sh
brew install tfenv
```
For other installation methods (e.g., Git clone), refer to the [tfenv installation guide](https://github.com/tfutils/tfenv#installation).

**Post-installation:**
Ensure `tfenv` is added to your shell's PATH. If installed via Homebrew, this is usually handled automatically. Otherwise, you might need to add `$(brew --prefix tfenv)/bin` (or the equivalent for your installation method) to your PATH.

### Terraform (via `tfenv`)

Once `tfenv` is installed, you can install specific Terraform versions:

1.  **List available Terraform versions**:
    ```sh
    tfenv list-remote
    ```

2.  **Install a specific version**:
    ```sh
    tfenv install <version>
    # Example: tfenv install 1.0.0
    ```
    To install the latest stable version:
    ```sh
    tfenv install latest
    ```

3.  **Select a Terraform version to use**:
    *   **Globally**:
        ```sh
        tfenv use <version>
        # Example: tfenv use 1.0.0
        ```
    *   **Per project (recommended)**: Create a `.terraform-version` file in your project's root directory containing the desired version number:
        ```
        # .terraform-version
        1.0.0
        ```
        `tfenv` will automatically pick up this version when you `cd` into the directory.

4.  **Verify installation**:
    ```sh
    terraform --version
    which terraform # Should point to a tfenv shim
    ```

## Basic Terraform Workflow

Terraform commands are typically run within a directory containing your `.tf` configuration files.

1.  **`terraform init`**: Initializes a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one.
    ```sh
    terraform init
    ```
    This command also initializes backend configuration (for state storage) and downloads provider plugins.

2.  **`terraform plan`**: Creates an execution plan. Terraform performs a refresh, unless explicitly disabled, and then determines what actions are necessary to achieve the desired state specified in the configuration files.
    ```sh
    terraform plan
    # Save the plan to a file:
    # terraform plan -out=tfplan
    ```
    This is a good way to check whether the proposed changes match your expectations before applying them.

3.  **`terraform apply`**: Applies the changes required to reach the desired state of the configuration, or the pre-determined changes if a plan file is provided.
    ```sh
    terraform apply
    # Apply a saved plan (prompts for confirmation):
    # terraform apply tfplan
    # Auto-approve (use with caution):
    # terraform apply -auto-approve
    # Or apply a saved plan without prompting:
    # terraform apply -auto-approve tfplan
    ```

4.  **`terraform destroy`**: Destroys all remote objects managed by a particular Terraform configuration.
    ```sh
    terraform destroy
    ```
    Use with extreme caution, as this will remove your managed infrastructure.

## Common Terraform Commands

*   **`terraform fmt`**: Rewrites Terraform configuration files to a canonical format and style.
    ```sh
    terraform fmt
    # Check for formatting issues: terraform fmt -check
    ```
*   **`terraform validate`**: Validates the syntax and arguments of configuration files.
    ```sh
    terraform validate
    ```
*   **`terraform output`**: Reads an output variable from a Terraform state file.
    ```sh
    terraform output <output_variable_name>
    ```
*   **`terraform state list`**: Lists resources within a Terraform state file.
    ```sh
    terraform state list
    ```
*   **`terraform workspace list/select/new/delete`**: Manages Terraform workspaces for different environments (e.g., dev, staging, prod).

## Resources

*   **Official Terraform Documentation**: [https://developer.hashicorp.com/terraform/docs](https://developer.hashicorp.com/terraform/docs)
*   **Terraform CLI Commands**: [https://developer.hashicorp.com/terraform/cli/commands](https://developer.hashicorp.com/terraform/cli/commands)
*   **`tfenv` GitHub Repository**: [https://github.com/tfutils/tfenv](https://github.com/tfutils/tfenv)
*   **Terraform Registry (Providers & Modules)**: [https://registry.terraform.io/](https://registry.terraform.io/)

This document provides fundamental guidance. Terraform is a comprehensive tool; always refer to the official documentation for detailed information and best practices.
