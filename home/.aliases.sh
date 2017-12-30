alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/dev"
alias dotf="cd ~/.dot"

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update; sudo gem cleanup'

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

alias lock='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CG\Session -suspend'
alias -g C='| xargs echo -n | pbcopy'

# Copy my public key to the pasteboard
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | printf '=> Public key copied to pasteboard.\n'"
alias wifi="wifi-password"

# swap python env
alias pip3="source activate python3"
alias pip2="source deactivate"

#gcloud commands
alias gstart="gcloud compute instances start"
alias gstop="gcloud compute instances stop"
alias ssh-fastai="gcloud compute ssh jon@fastai"
alias open-fastai="open http://35.201.182.120:8888/"