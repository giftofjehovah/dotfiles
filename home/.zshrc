# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh
eval "$(rbenv init -)"
export ZSH_THEME="agnoster"
# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"
export PATH=~/Library/Python/2.7/bin/:$PATH
 #disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"
# disable colors in ls
# export DISABLE_LS_COLORS="true"
# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"
# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git npm brew osx extract z zsh-syntax-highlighting zsh-autosuggestions)
# customise promot for agnoster theme
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)"
  fi
}
source $ZSH/oh-my-zsh.sh
source $HOME/.aliases.sh
source $HOME/.functions.sh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTRS=(main brackets pattern cursor root line)

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="/Users/jon/anaconda/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jon/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/jon/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jon/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/jon/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
