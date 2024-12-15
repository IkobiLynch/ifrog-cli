#!/bin/bash
# Script that installs the cli. 
# Make this script exeutable by using command chmod o+x ./ifrog_setup.sh
# Then run this script and it will install the cli and man page
# Likely does not work on windows OS!

set -euo pipefail

echo "Starting ifrog CLI installation..."

# Step 1: Check dependencies
echo "Checking for required dependencies: jq and curl"

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Installing jq..."
    if command -v brew >/dev/null 2>&1; then
        echo "Using Homebrew to install jq..."
        brew install jq
    elif [[ -x "$(command -v apt-get)" ]]; then
        echo "Using apt-get to install jq..."
        sudo apt-get update && sudo apt-get install -y jq
    elif [[ -x "$(command -v yum)" ]]; then
        echo "Using yum to install jq..."
        sudo yum install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Homebrew is not available. Installing jq manually for macOS..."
        JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
        curl -L "$JQ_URL" -o /usr/local/bin/jq
        chmod +x /usr/local/bin/jq
    else
        echo "Unsupported environment for automatic jq installation. Please install jq manually."
        exit 1
    fi
else
    echo "jq is already installed."
fi

# Check if curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found. Please install curl before proceeding."
    exit 1
fi

# Step 2: Make .ifrog dir in HOME
INSTALL_DIR="/usr/local/bin"
mkdir ~/.ifrog
cp ./config.example.json ~/.ifrog/config.json

# Step 3: Move ifrog.sh to /usr/local/bin/ and rename to 'ifrog'
echo "Installing ifrog CLI to $INSTALL_DIR..."
sudo cp "./ifrog.sh" "$INSTALL_DIR/ifrog"
sudo chmod +x "$INSTALL_DIR/ifrog"

# Step 4: Install man page to custom directory
CUSTOM_MAN_DIR="$HOME/.man/man/man1"
echo "Setting up custom man directory at $CUSTOM_MAN_DIR..."
mkdir -p "$CUSTOM_MAN_DIR"

echo "Installing the man page for ifrog..."
cp "./ifrog.1" "$CUSTOM_MAN_DIR/"
echo "Updating MANPATH..."
MANPATH=${MANPATH}
if [[ "$SHELL" =~ "zsh" ]]; then
    echo "export MANPATH=$HOME/.man/man:\$MANPATH" >> ~/.zshrc
    source ~/.zshrc
elif [[ "$SHELL" =~ "bash" ]]; then
    echo "export MANPATH=$HOME/.man/man:\$MANPATH" >> ~/.bash_profile
    source ~/.bash_profile
else
    echo "Shell not recognized. Please manually add the following to your shell configuration:"
    echo "export MANPATH=$HOME/.man/man:\$MANPATH"
fi


echo "ifrog CLI installation completed successfully!"
echo "Run 'ifrog --help' to get started."
echo "View detailed documentation with: man ifrog"
