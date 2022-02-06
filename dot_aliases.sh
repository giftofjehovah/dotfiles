alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/dev"
alias dev-w="cd ~/dev/work"
alias dev-p="cd ~/dev/personal" 
alias dotf="cd ~/.local/share/chezmoi"

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
# alias wifi="wifi-password"

# swap python env
# alias pip3="source activate python3"
# alias pip2="source deactivate"

# gcloud commands
alias gstart="gcloud compute instances start"
alias gstop="gcloud compute instances stop"
alias ssh-fastai="gcloud compute ssh jon@fast-ai"
alias open-fastai="open http://35.201.182.120:8888/"

# docker commands
alias d="docker"
alias dc="docker-compose"

# replace cli commands with more useful ones
alias cat="bat"
alias ping="prettyping --nolegend"
alias preview="fzf --preview 'bat --color \"always\" {}'"
alias top="htop"
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias help='tldr'

# project based aliases
alias refreshCC="sh ~/delete-code-commit-keychain.sh"

# colorls
alias ls='colorls --group-directories-first'
alias la='colorls --group-directories-first --almost-all'
alias ll='colorls --group-directories-first --almost-all --long'