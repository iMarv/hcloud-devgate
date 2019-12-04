export ZSH="/home/${user_name}/.oh-my-zsh"

ZSH_THEME="fino"

plugins=(git zsh-autosuggestions shrink-path)

source $ZSH/oh-my-zsh.sh

alias cat=bat
alias ls=exa
alias mist='cat /var/log/cloud-init-output.log'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fpath=(~/.zsh/completion $fpath)
fpath+=~/.zfunc

eval "$(ssh-agent)"
