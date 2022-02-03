#!/usr/bin/env bash

source ~/.local/share/chezmoi/helpers/echos.sh
source ~/.local/share/chezmoi/helpers/requirers.sh 

sudo xcodebuild -license accept

mackup restore

bot "installing fonts"
cp ~/.local/share/chezmoi/fonts/*.ttf ~/Library/Fonts/
ok "All fonts installed"

mkdir ~/dev

pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
[[ -f $pub ]] || ssh-keygen -t rsa

brew cleanup

