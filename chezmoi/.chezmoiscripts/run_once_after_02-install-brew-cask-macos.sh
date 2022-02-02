#!/usr/bin/env bash

###############################################################################
# Install Homebrew Cask (UI Packages)                                         #
###############################################################################

source ~/.local/share/chezmoi/helpers/echos.sh
source ~/.local/share/chezmoi/helpers/requirers.sh 

running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  action "adding tap brew-cask"
  require_brew homebrew/cask
fi
brew tap homebrew/cask > /dev/null 2>&1
ok

action "adding tap brew-cask fonts"
brew tap homebrew/cask-fonts
ok

action "adding tap onivim2"
brew tap marblenix/onivim2
ok