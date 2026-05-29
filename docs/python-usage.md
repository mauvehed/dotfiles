# Python Usage

This document provides a guide to setting up and using Python for development, focusing on version management with `pyenv`, and modern project/dependency management with tools like Poetry and `venv`.

## Overview

[Python](https://www.python.org/) is a versatile, high-level programming language. Effective Python development involves managing Python versions and project dependencies robustly.

## Python Version Management with `pyenv`

It is highly recommended to use [pyenv](https://github.com/pyenv/pyenv) to manage multiple Python versions.

### Installation of `pyenv`

*   **Homebrew (macOS)**:
    ```sh
    brew install pyenv
    ```
*   **Other Systems/Manual Install**: Follow the [official `pyenv` installation guide](https://github.com/pyenv/pyenv#installation).

### `pyenv` Initialization

Add `pyenv` init to your shell configuration file (e.g., `.zshrc`), managed by `chezmoi`:
```sh
# Example for .zshrc
# if command -v pyenv 1>/dev/null 2>&1; then
#  eval "$(pyenv init -)"
#  eval "$(pyenv virtualenv-init -)" # If using pyenv-virtualenv (optional)
# fi
```

### Installing Python Versions with `pyenv`

1.  **List available Python versions**: `pyenv install --list`
2.  **Install a Python version**: `pyenv install <version>` (e.g., `pyenv install 3.10.4`)
3.  **Set Python version**:
    *   **Globally**: `pyenv global <version>`
    *   **Locally (per-project)**: `pyenv local <version>` (creates `.python-version`)
    *   **Shell specific**: `pyenv shell <version>`

## Project & Dependency Management

Isolating project dependencies is crucial.

### Option 1: Poetry (Recommended for New Projects)

[Poetry](https://python-poetry.org/) is a modern tool for Python dependency management and packaging. It helps you declare, manage, and install dependencies of Python projects, ensuring you have the right stack everywhere.

**Key Benefits of Poetry:**
*   **Dependency Resolution**: Advanced resolver for compatible dependencies.
*   **Unified Tool**: Manages project metadata, dependencies, virtual environments, building, and publishing.
*   **`pyproject.toml`**: Uses the standard `pyproject.toml` file to manage project information.
*   **Lock File**: Creates a `poetry.lock` file for deterministic builds.
*   **Virtual Environment Management**: Automatically creates and manages virtual environments for your projects.

**Installation of Poetry:**

Refer to the [official Poetry installation guide](https://python-poetry.org/docs/#installation). A common method is using their custom installer or `pipx`:
```sh
# Using pipx (recommended for CLI tools)
brew install pipx # If not already installed
pipx ensurepath
pipx install poetry

# Or using the official installer
# curl -sSL https://install.python-poetry.org | python3 -
```

**Common Poetry Commands:**

*   **`poetry new <project_name>`**: Creates a new Python project with a standard structure.
*   **`poetry init`**: Interactively creates a `pyproject.toml` in an existing project.
*   **`poetry install`**: Installs dependencies defined in `pyproject.toml` (and `poetry.lock`). If a virtual environment doesn't exist, Poetry creates one.
*   **`poetry add <package_name>`**: Adds a new dependency to `pyproject.toml` and installs it.
    *   `poetry add requests`
    *   `poetry add pytest --group dev` (for development dependencies)
*   **`poetry remove <package_name>`**: Removes a dependency.
*   **`poetry show`**: Lists all installed packages.
*   **`poetry update`**: Updates dependencies to their latest allowed versions according to `pyproject.toml` and updates `poetry.lock`.
*   **`poetry run <command>`**: Runs a command within the project's virtual environment.
    *   `poetry run python my_script.py`
    *   `poetry run pytest`
*   **`poetry shell`**: Activates the project's virtual environment in your current shell.
*   **`poetry build`**: Builds your project into a source archive (sdist) and a wheel (bdist_wheel).
*   **`poetry publish`**: Publishes your package to a repository like PyPI.

Poetry can be configured to use Python versions installed by `pyenv`:
```sh
poetry env use $(pyenv which python) # Or specify a path/version
```

### Option 2: `venv` and `pip` (Traditional)

Python 3.3+ includes the `venv` module for creating virtual environments.

1.  **Create a virtual environment**: `python -m venv .venv`
2.  **Activate**:
    *   Unix/macOS: `source .venv/bin/activate`
    *   Windows: `.\.venv\Scripts\activate.bat` or `.\.venv\Scripts\Activate.ps1`
3.  **Deactivate**: `deactivate`

**Package Management with `pip` (within an active `venv`)**:

*   Install: `pip install <package_name>`, `pip install -r requirements.txt`
*   List: `pip list`
*   Generate `requirements.txt`: `pip freeze > requirements.txt`

### `pyenv-virtualenv` (Plugin for `pyenv`)

The [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv) plugin integrates `venv` management with `pyenv` if you prefer this workflow over Poetry's built-in virtual environment handling.

## Common Python Development Tools

Install these within your project's virtual environment (via `poetry add --group dev tool_name` or `pip install tool_name`) or globally via `pipx`.

*   **Linters**: `flake8`, `pylint`
*   **Formatters**: `black`, `autopep8`, `isort`
*   **Test Runners**: `pytest`, `unittest` (built-in)
*   **`pipx`**: For installing and running Python CLI applications in isolated environments (`brew install pipx`).
    *   Example: `pipx install black`

## Resources

*   **Official Python Documentation**: [https://docs.python.org/3/](https://docs.python.org/3/)
*   **`pyenv` GitHub Repository**: [https://github.com/pyenv/pyenv](https://github.com/pyenv/pyenv)
*   **Poetry Documentation**: [https://python-poetry.org/docs/](https://python-poetry.org/docs/)
*   **Python `venv` Documentation**: [https://docs.python.org/3/library/venv.html](https://docs.python.org/3/library/venv.html)
*   **`pip` Documentation**: [https://pip.pypa.io/](https://pip.pypa.io/)
*   **Python Packaging User Guide**: [https://packaging.python.org/](https://packaging.python.org/)
*   **`pipx`**: [https://pipx.pypa.io/](https://pipx.pypa.io/)

This document covers essentials for a modern Python development setup. Choose the tools that best fit your project needs.
