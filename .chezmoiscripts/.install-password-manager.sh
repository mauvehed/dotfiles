#!/bin/bash

set -eufo pipefail

case "$(uname -s)" in
Darwin)
    # Function to download and install 1Password UI app
    install_1password_ui_macos() {
        echo "Downloading 1Password zip file..."
        /usr/bin/curl -o "$DOWNLOAD_DIR/1Password.zip" "$ZIP_URL"

        if [ $? -ne 0 ]; then
            echo "Failed to download 1Password zip file."
            exit 1
        fi

        echo "Extracting 1Password application..."
        unzip -q "$DOWNLOAD_DIR/1Password.zip" -d "$DOWNLOAD_DIR"

        if [ $? -ne 0 ]; then
            echo "Failed to extract 1Password application."
            exit 1
        fi

        echo "Moving 1Password application to Applications folder..."
        mv "$DOWNLOAD_DIR/1Password.app" "$TARGET_DIR/"

        if [ $? -ne 0 ]; then
            echo "Failed to move 1Password application to Applications folder."
            exit 1
        fi

        success "1Password.app installation completed successfully."
    }

    # Function to install 1Password CLI app
    install_1password_cli_macos() {
        if [ -x "/opt/homebrew/bin/brew" ]; then
            echo "Homebrew is already installed."
        else
            echo "Homebrew is not installed. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            if [ $? -ne 0 ]; then
                echo "Failed to install Homebrew."
                exit 1
            fi
        fi

        if [ -x "/opt/homebrew/bin/brew" ]; then
            /opt/homebrew/bin/brew install --cask 1password-cli

            if [ $? -ne 0 ]; then
                echo "Failed to install 1Password CLI."
                exit 1
            fi
        else
            echo "/opt/homebrew/bin/brew not found. Cannot install 1Password CLI."
            exit 1
        fi
    }

    # define the URL of the zip file
    ZIP_URL="https://downloads.1password.com/mac/1Password.zip"

    # define the download directory
    DOWNLOAD_DIR="$HOME/Downloads"

    # define the target directory to extract the application
    TARGET_DIR="/Applications"

    # check if 1Password UI app is installed
    if [ ! -d "/Applications/1Password.app" ]; then
        echo "installing 1password.app"
        install_1password_ui_macos
    fi

    # check if 1Password CLI app is installed
    if [ ! -x "/opt/homebrew/bin/op" ]; then
        echo "installing 1password-cli"
        install_1password_cli_macos
    fi
    ;;
Linux)
    # Function to install 1Password CLI app
    install_1password_cli_linux() {
        # Function to check return status and exit if error
        check_status() {
            if [ $? -ne 0 ]; then
                echo "Error: $1 failed"
                exit 1
            fi
        }

        # Import 1Password GPG key
        sudo -s <<EOF
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
EOF
        check_status "Importing GPG key"

        # Add 1Password repository to sources.list.d
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
        check_status "Adding repository to sources.list.d"

        # Create directory for debsig policies and import 1Password debsig policy
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        check_status "Importing debsig policy"

        # Create directory for debsig keyrings and import 1Password debsig keyring
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        check_status "Importing debsig keyring"

        # Update package lists and install 1Password CLI
        sudo apt update
        sudo apt install -y 1password-cli
        check_status "Installing 1password-cli .deb packages"

        if dpkg -l | grep -q "1password-cli"; then
            echo "1Password CLI installed successfully."
            echo "Don't forget the `eval $(op signin)`"
        fi
    }

    # check if 1Password CLI app is installed
    if [ ! -x "/usr/bin/op" ]; then
        echo "Starting 1password-cli installation routine"
        install_1password_cli_linux
    fi
    ;;
*)
    # nothing to do other OSes
    ;;
esac
