#!/bin/bash

# Reusable Vars
HEADERDIV=##############################################

# List Applications to be Installed for confirmation
echo $HEADERDIV
echo "Install List"
echo $HEADERDIV

echo "x-code-select"
echo "Homebrew"
{
    read # Skip the header row
    while IFS=, read -r id name source; do 
        echo "$name"; 
    done
} < "requirements.csv"

echo ""
echo ""

read -p "Are you sure you want to install/upgrade these apps (Y/[N])? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# Install Applications
echo $HEADERDIV
echo "Starting Installation"
echo $HEADERDIV

# Install x-code-select
xcode-select --install

# Install Homebrew
echo "Installing Homebrew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add homebrew to path
echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc && source ~/.zshrc

# Install applications in requirements.csv
{
    read
    while IFS=, read -r formula name source; do 
        echo "Installing $name"
        brew install $formula
    done
 } < "requirements.csv"

# Set default editor
git config --global core.editor "nano"

echo ""
echo ""
echo "Done!"