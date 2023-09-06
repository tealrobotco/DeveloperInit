#!/bin/bash

# Reusable Vars
HEADERDIV=##############################################

# List Applications to be Installed for confirmation
echo $HEADERDIV
echo "Install List"
echo $HEADERDIV

echo "Oh My ZSH"
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

# If OH MY ZSH is installed, run zsh
LINE='export ZSH="$HOME/.oh-my-zsh"'
if grep -Fxq "$LINE" "$HOME/.zshrc"; then
    # assume Zsh
    echo "Oh My ZSH is installed."
else
    # assume Bash
    echo "Oh My ZSH is not installed. Installing now."
    rm -rf $HOME/.oh-my-zsh # remove install dir if exists
    # Install oh my zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Add homebrew to path if line is not already there
echo "Adding Homebrew to your path and zshrc file."
LINE='export PATH=/opt/homebrew/bin:/opt/homebrew/anaconda3/bin:$PATH'
grep -qF -- "$LINE" "$HOME/.zshrc" || echo "$LINE" >> "$HOME/.zshrc" || exit 1
grep -qF -- "$LINE" "$HOME/.bash_profile" || echo "$LINE" >> "$HOME/.bash_profile" || exit 1
PATH=/opt/homebrew/bin:/opt/homebrew/anaconda3/bin:$PATH

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
echo "Done! Launching Oh My ZSH."

# load oh-my-zsh
zsh