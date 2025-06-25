#zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

bindkey -v
export KEYTIMEOUT=1

# compile zsh file, and source them - first run is slower
zsource() {
  local file=$1
  local zwc="${file}.zwc"
  if [[ -f "$file" && (! -f "$zwc" || "$file" -nt "$file") ]]; then
    zcompile "$file"
  fi
  source "$file"
}

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && zsource "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && zsource "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && zsource "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Created by newuser for 5.9
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
#source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
#zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
#zinit light zsh-users/zsh-syntax-highlighting
#zinit light zsh-users/zsh-completions
#zinit light zsh-users/zsh-autosuggestions
#zinit light Aloxaf/fzf-tab
#zinit light softmoth/zsh-vim-mode

# Add in snippets
#zinit snippet OMZP::git

# Plugins
zsource $ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
zsource $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
zsource $ZDOTDIR/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh
zsource $ZDOTDIR/plugins/zsh-completions/zsh-completions.plugin.zsh
#source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Load completions
#autoload -U compinit && compinit
autoload -Uz compinit
ZSH_COMPDUMP="${ZDOTDIR}/.zcompdump"
compinit -C -d "$ZSH_COMPDUMP"
zsource $ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh

#zinit cdreplay -q

# Detect the AUR wrapper
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null ; then
            arch+=("${pkg}")
        else 
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
#bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey -s '^o' "code-search.sh\n"
#bindkey -s '^o' "pacman -Qq | fzf-tmux -h60% -w70% --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'\n"

# Custom Commands and Keybindings
browsing_packages() {
  BUFFER="pacman -Qq | fzf-tmux -h60% -w70% --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
  zle accept-line
}
zle -N browsing_packages
bindkey '^X' browsing_packages

# This command takes all changed files and commits them with the date and some machine information. 
dotfiles_autoupdate() {
    config add -u && \
    config commit -m "Update $(date +"%Y-%m-%d %H:%M") \
        $(uname -s)/$(uname -m)-$HOST" && config push -u origin main
}

# History in cache directory:
HISTSIZE=10000000
#HISTFILE=$HOME/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# fzf completion and keybindings
#source ~/.config/fzf/key-bindings-rg.zsh 2>/dev/null
#source ~/.config/fzf/key-bindings-ag.zsh 2>/dev/null
#source ~/Downloads/colt.sh 2>/dev/null
zsource ~/.config/fzf/colt-tmux.sh 2>/dev/null
#source /usr/share/fzf/key-bindings.zsh 2>/dev/null

unset ZSH_AUTOSUGGEST_USE_ASYNC

#Display Pokemon
#pokemon-colorscripts --no-title -r 1,3,6

# Shell integretions
#eval "$(fzf --zsh)"

# Initialize starship prompt
eval "$(starship init zsh)"

#zprof > /tmp/foobar
