# AWS Usage

This document provides an overview of using Amazon Web Services (AWS) tools, primarily the AWS Command Line Interface (CLI), within this dotfiles setup.

## Overview

The AWS CLI is a unified tool to manage your AWS services. This guide covers basic configuration and common commands.

## Prerequisites

*   **AWS Account**: An active AWS account.
*   **AWS CLI Installed**: The AWS CLI is typically installed via Homebrew as part of the `chezmoi` setup if specified in your configurations.
    ```sh
    brew install awscli
    ```
*   **Configured Credentials**: AWS CLI needs credentials to interact with your AWS account. These are typically stored in `~/.aws/credentials` and `~/.aws/config`.
    *   **Security Note**: It is highly recommended to manage AWS credentials securely, for example, by storing them in 1Password and having `chezmoi` templates populate the AWS configuration files, or by using a tool like `aws-vault`.

## Configuration

AWS CLI configuration can be managed via `aws configure` or by directly editing the files:

*   `~/.aws/config`: Stores default region, output format, and named profiles.
*   `~/.aws/credentials`: Stores AWS access keys for different profiles.

### Example `~/.aws/config`:
```ini
[default]
region = us-east-1
output = json

[profile my-other-profile]
region = us-west-2
output = text
```

### Example `~/.aws/credentials` (managed via 1Password/`chezmoi` or `aws-vault`):
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID_DEFAULT
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_DEFAULT

[profile my-other-profile]
aws_access_key_id = YOUR_ACCESS_KEY_ID_OTHER
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_OTHER
```

Refer to `docs/1password-usage.md` for guidance on storing these credentials in 1Password and using `chezmoi` templates.

## `aws-vault` (Recommended for Enhanced Security)

[aws-vault](https://github.com/99designs/aws-vault) is a tool to securely store and access AWS credentials in your operating system's keystore. It helps in avoiding storing AWS credentials in plaintext files.

### Installation (if not managed by `chezmoi`):
```sh
brew install aws-vault
```

### Basic Usage:

1.  **Add credentials to `aws-vault`**:
    ```sh
    aws-vault add my-profile
    ```
    (This will prompt for your access key ID and secret access key)

2.  **Execute commands using a profile**:
    ```sh
    aws-vault exec my-profile -- aws s3 ls
    ```

## Common AWS CLI Commands

Replace `my-profile` with your desired AWS profile if not using `default`.

*   **List S3 Buckets**:
    ```sh
    aws s3 ls --profile my-profile
    # Using aws-vault:
    # aws-vault exec my-profile -- aws s3 ls
    ```

*   **List EC2 Instances**:
    ```sh
    aws ec2 describe-instances --profile my-profile
    # Using aws-vault:
    # aws-vault exec my-profile -- aws ec2 describe-instances
    ```

*   **Get Caller Identity (useful for verifying current credentials)**:
    ```sh
    aws sts get-caller-identity --profile my-profile
    # Using aws-vault:
    # aws-vault exec my-profile -- aws sts get-caller-identity
    ```

## Resources

*   **Official AWS CLI Documentation**:
    *   [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)
    *   [AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/index.html)
*   **`aws-vault` GitHub Repository**: [https://github.com/99designs/aws-vault](https://github.com/99designs/aws-vault)
*   **1Password Documentation**: Refer to `docs/1password-usage.md` for managing secrets.

This document is a starting point. Please refer to the official documentation for comprehensive information.
