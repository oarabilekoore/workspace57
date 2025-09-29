#
# ~/.bashrc

export MONITOR_NAME=$(hyprctl monitors -j | jq -r '.[0].name')

dev() {
  local base_dir="$HOME/Development"
  local target="$base_dir/$1"

  if [ -z "$1" ]; then
    echo "Usage: zedv <projectName>"
    return 1
  fi

  if [ -d "$target" ]; then
    # Open kitty in the target directory (independent process)
    kitty --working-directory="$target" &
    disown

    # Open nvim in the same directory (foreground process)
    cd "$target" || return
    zed .
  else
    echo "Project '$1' not found in $base_dir"
    return 1
  fi
}

# Open the config folder
cfg() {
  local base_dir="$HOME/.config"
  local target="$base_dir/$1"

  if [ -z "$1" ]; then
    echo "Usage: cfg <configDirectory>"
  fi

  if [ -d "$target" ]; then
    cd "$target" || return
    nvim
  else
    echo "Config Folder '$1' not found in $base_dir"
    return 1
  fi
}

# Make a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

alias sleep='sudo systemctl suspend'
alias die='shutdown'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias info='pacman -Si'
alias files='pacman -Ql'
alias owner='pacman -Qo'
alias rmorphan='sudo pacman -Rns $(pacman -Qdtq)'

alias gpu='git push'
alias gcl='git clone'

# Safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Better ls
alias ls='ls --color=auto -F'
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
fastfetch

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
export PATH=$HOME/.local/bin:$PATH
