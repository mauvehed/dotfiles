# Go (Golang) Usage

This document provides a guide to setting up and using the Go programming language, including managing versions and common commands.

## Overview

[Go](https://go.dev/) (often referred to as Golang) is an open-source programming language designed by Google. It is known for its simplicity, efficiency, strong support for concurrency, and robust standard library.

## Installation

There are several ways to install Go:

*   **Official Installers**: Download from [go.dev/dl/](https://go.dev/dl/).
*   **Homebrew (macOS)**:
    ```sh
    brew install go
    ```
    This usually installs the latest stable version.
*   **Go Version Manager (`goenv`)** (Recommended for managing multiple Go versions):
    [goenv](https://github.com/syndbg/goenv) lets you easily switch between multiple versions of Go. It's similar to `pyenv` for Python or `tfenv` for Terraform.

    **Installation of `goenv` (macOS with Homebrew):**
    ```sh
    brew install goenv
    ```
    For other systems or manual install, see the [goenv installation guide](https://github.com/syndbg/goenv#installation).

    **Using `goenv`:**
    1.  Initialize `goenv` in your shell (add to `.zshrc` or `.bashrc`, managed by `chezmoi`):
        ```sh
        # Example for .zshrc
        # if command -v goenv 1>/dev/null 2>&1; then
        #   eval "$(goenv init -)"
        # fi
        ```
    2.  List available Go versions to install:
        ```sh
        goenv install -l
        ```
    3.  Install a specific Go version:
        ```sh
        goenv install <version>
        # Example: goenv install 1.18.3
        ```
    4.  Set global or local (per-project) Go version:
        ```sh
        goenv global <version> # Sets the default Go version
        goenv local <version>  # Creates a .go-version file in the current directory
        ```

If `chezmoi` manages your Go installation, it will handle the chosen installation method.

## Environment Variables

Go uses several environment variables to configure its behavior:

*   **`GOROOT`**: The root of your Go installation (e.g., `/usr/local/go` or a path managed by `goenv`). Usually set automatically.
*   **`GOPATH`**: Defines the root of your workspace. Before Go Modules, it was crucial for organizing Go code and compiled binaries. With Go Modules, its role has diminished but it still defines a default location for `go install` outside a module (`$HOME/go` by default).
*   **`GOBIN`**: The directory where `go install` will place compiled binaries (if set). If not set, binaries are placed in `$GOPATH/bin` (or `$HOME/go/bin`).
*   **`GO111MODULE`**: Controls Go Modules behavior.
    *   `on`: Forces module-aware mode (default in Go 1.16+).
    *   `auto`: Enables module mode if a `go.mod` file is present in the current or any parent directory.
    *   `off`: Disables module mode, uses `GOPATH` mode.

These are typically set in your shell profile (`.zshrc`, `.bash_profile`), managed by `chezmoi`.

## Basic Go Commands

*   **`go version`**: Displays the current Go version.
    ```sh
    go version
    ```

*   **`go run <filename.go>`**: Compiles and runs a Go program.
    ```sh
    go run main.go
    ```

*   **`go build [packages]`**: Compiles packages and their dependencies. Creates an executable in the current directory (for `main` packages).
    ```sh
    go build
    go build ./cmd/myprogram
    ```

*   **`go install [packages]`**: Compiles and installs packages. Executables are placed in `$GOBIN` or `$GOPATH/bin`.
    ```sh
    go install github.com/user/project/cmd/mytool@latest
    ```

*   **`go test [packages]`**: Runs tests for the specified packages.
    ```sh
    go test ./...
    go test -v ./mypackage
    ```

*   **`go get [packages]`**: (Legacy behavior with Go Modules) Adds dependencies to `go.mod` and installs them. For installing tools, prefer `go install tool@version`.

## Go Modules

Go Modules are used for dependency management.

*   **`go mod init <module_path>`**: Initializes a new module in the current directory, creating a `go.mod` file.
    ```sh
    go mod init github.com/myuser/myproject
    ```

*   **`go mod tidy`**: Adds missing and removes unused modules from `go.mod` and `go.sum`.
    ```sh
    go mod tidy
    ```

*   **`go mod download`**: Downloads modules to the local cache.
    ```sh
    go mod download
    ```

*   **`go list -m all`**: Lists all modules used in the current project.

## Common Go Tools

*   **`gofmt`**: Formats Go programs.
    ```sh
    gofmt -w main.go # Formats and writes back to file
    ```
*   **`goimports`**: Updates your Go import lines, adding missing and removing unreferenced ones (superset of `gofmt`). Install with `go install golang.org/x/tools/cmd/goimports@latest`.
*   **`golint` / `staticcheck` / `golangci-lint`**: Linters for Go code. `golangci-lint` is a popular meta-linter.

## Resources

*   **Official Go Website**: [https://go.dev/](https://go.dev/)
*   **Go Documentation**: [https://go.dev/doc/](https://go.dev/doc/)
*   **Effective Go (Best Practices)**: [https://go.dev/doc/effective_go](https://go.dev/doc/effective_go)
*   **Go Modules Reference**: [https://go.dev/ref/mod](https://go.dev/ref/mod)
*   **`goenv` GitHub Repository**: [https://github.com/syndbg/goenv](https://github.com/syndbg/goenv)
*   **Go Playground**: [https://go.dev/play/](https://go.dev/play/)

This document provides a starting point for working with Go. Refer to the official documentation for more in-depth information.
