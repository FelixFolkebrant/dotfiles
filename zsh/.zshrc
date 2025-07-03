# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Manual Zsh plugin management, no Oh My Zsh

# Add plugins to your fpath if needed
# fpath+=($HOME/.zsh/plugins/zsh-completions/src)

# Source plugins
source $HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Powerlevel10k prompt
source $HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Fuzzy finder integration (if you have fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Your own aliases, functions, and config below
# alias ll="ls -alF"

# Keybind functions

function go_home() {
  cd ~
  zle accept-line
}

zle -N go_home

# Keybinds
bindkey '^ ' autosuggest-accept
bindkey '^j' history-search-forward
bindkey '^k' history-search-backward
bindkey '^f' fzf-file-widget
bindkey '\e[1;6F' fzf-cd-widget

bindkey '^h' go_home


# Aliases

alias lg='lazygit'
alias lsa='ls -a'
alias pms='sudo pacman -S'
alias pmss='sudo pacman -S --noconfirm'
alias pmr='sudo pacman -Rns'
alias pmu='sudo pacman -Syu'

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Completion styling
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  

# Aliases
alias ls='ls --color'

# Binaries path
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

