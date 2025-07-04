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

# FZF fuzzy finder
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Dont really like this aproach. Problem: Same cutof at half monitor on both vert and hor.
# Best: Cutoff horizontal monitor at w/4 and vert at w/2
if [ "$(tput cols)" -ge 50 ]; then
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
else
  export FZF_CTRL_T_OPTS=""
  export FZF_ALT_C_OPTS=""
fi

# Keybind functions

function go_home() {
  cd ~
  zle accept-line
}

zle -N go_home

# Keybinds
bindkey '^[[Z' autosuggest-accept
bindkey '^j' history-search-forward
bindkey '^k' history-search-backward
bindkey '^f' fzf-file-widget
bindkey '\e[1;6F' fzf-cd-widget
bindkey '^g' go_home


# Aliases

alias lg='lazygit'

alias ls='eza --color=always --icons'
alias lst='eza --tree --color=always --level=2 --icons=always'
alias lsa='eza -a --icons --color=always'
alias lsl='eza --icons --color=always --oneline'

alias ..='cd ..'

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

# Binaries path
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

