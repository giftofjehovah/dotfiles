# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh
eval "$(rbenv init -)"
export ZSH_THEME="spaceship"
# export ZSH_THEME="agnoster"
# export ZSH_THEME="hyperzsh"
# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"
export PATH=~/Library/Python/2.7/bin/:$PATH
export PATH=~/anaconda2/bin:$PATH
export PATH=/usr/local/bin/npm:$PATH
 #disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"
# disable colors in ls
# export DISABLE_LS_COLORS="true"
# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"
# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git npm brew macos extract z zsh-syntax-highlighting zsh-autosuggestions vi-mode asdf)
# customise promot for agnoster theme
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)"
  fi
}
source $ZSH/oh-my-zsh.sh
source $HOME/.aliases.sh
source $HOME/.functions.sh
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
ZSH_HIGHLIGHT_HIGHLIGHTRS=(main brackets pattern cursor root line)

export PATH="$HOME/.yarn/bin:$PATH"
export PATH="/Users/jon/anaconda/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jon/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/jon/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jon/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/jon/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
export PATH=/Users/jon/.local/bin/luna-studio:$PATH

# Set Spaceship ZSH as a prompt
# autoload -U promptinit; promptinit
# prompt spaceship

# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /usr/local/Cellar/node/12.4.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /usr/local/Cellar/node/12.4.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
export PATH=/Users/jon/.local/bin:$PATH

  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"
