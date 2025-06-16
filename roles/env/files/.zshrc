eval "$(/opt/homebrew/bin/brew shellenv)"

# Created by `pipx` on 2024-10-24 21:57:28
export PATH="$PATH:${HOME}/local/bin"
# paths and aliases preferences
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="${HOME}/bin:${PATH}"
export PATH="$HOME/.local/bin:$PATH"
#export DOCKER_HOST=unix://Users//$USER/.docker/run/docker.sock
#export GODEBUG=asyncpreemptoff=1

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/richardlam/.lmstudio/bin"

alias dateu='echo && date && date -u && echo'
alias google='_google'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipa="echo; ifconfig | awk '/^[a-z]/ {interface=\$1} /inet / {print interface, \$2}' | grep -v '127.0.0.1' | sed -E 's/^([^ ]+)/\x1b[1;34m\1\x1b[0m/; s/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/\x1b[1;31m\1\x1b[0m/'; echo"
alias g='git'

function _google() {
    local encoded_query
    encoded_query=$(printf "%s" "$*" | jq -sRr @uri)
    open "https://www.google.com/search?q=${encoded_query}"
}

# https://dev.to/cassidoo/customizing-my-zsh-prompt-3417
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
autoload -Uz colors && colors
autoload -Uz vcs_info
precmd() { vcs_info }

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%{$fg[blue]%}%n%{$reset_color%}@%{$fg[red]%}%m %{$fg[green]%}|${vcs_info_msg_0_}%{$fg[yellow]%}%~ %{$reset_color%}%% '

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=$HISTSIZE
export HISTORY_IGNORE="(cd|clear|pwd|exit|cd ..|cd ../..)"
export HIST_STAMPS=no

setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# default color scheme
#export LSCOLORS=exfxcxdxbxegedabagacad
export LS_OPTIONS='--color=always'
export CLICOLOR=1
export LSCOLORS=ExGxFxdxCxDxDxhbadExEx
alias grep='grep --color=auto'

export MANPAGER=most

# kubectl
#alias k='kubectl'
#source <(kubectl completion zsh)
#alias kgs='f() { kubectl get secret $1 -o json | jq ".data | map_values(@base64d)" };f'

# aws
complete -C '/opt/homebrew/bin/aws_completer' aws

# terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

_uv_run_mod() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  if [[ $words[2] == run && $CURRENT -ge 3 && ${words[CURRENT]} != -* ]]; then
    _arguments '*:Python file:_files -g "*.py"'
  else
    _uv "$@"
  fi
}
compdef _uv_run_mod uv


# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height 80%
  --layout reverse
  --multi
  --border
  --highlight-line --color gutter:-1,selected-bg:238,selected-fg:146,current-fg:189"

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# CTRL-/ to toggle small preview window to see the full command
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header '
Press CTRL-P: toggle preview
Press CTRL-Y to copy command into clipboard
'"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

# this function obtained from:
# https://thevaluable.dev/practical-guide-fzf-example/
function se {
    if [ -z "$1" ]; then
        search_folder="$HOME"
    else
        search_folder="$1"
    fi

    #find_params="-type d \( -name Library -o -name Music -o -name Movies \) -prune -o -print "
    #selection=$(find "$search_folder" "$find_params" | fzf --multi --height=80% --border=sharp \

    selection=$(find "$search_folder" -type d \( -name "Library" -o -name "Music" -o -name "Movies" -o -name ".Trash" \) -prune -o -print | fzf --multi --height=80% --border=sharp \
        --preview='tree -C {}' --preview-window='50%' \
        --prompt='Dirs > ' \
        --bind='del:execute(rm -ri {+})' \
        --bind='ctrl-p:toggle-preview' \
        --bind='ctrl-d:change-prompt(Dirs > )' \
        --bind="ctrl-d:+reload(find $search_folder -type d \( -name \"Library\" -o -name \"Music\" -o -name \"Movies\" \) -prune -o -print )" \
        --bind='ctrl-d:+change-preview(tree -C {})' \
        --bind='ctrl-d:+refresh-preview' \
        --bind='ctrl-f:change-prompt(Files > )' \
        --bind="ctrl-f:+reload(find $search_folder -type d \( -name \"Library\" -o -name \"Music\" -o -name \"Movies\" \) -prune -o -type f -print )" \
        --bind='ctrl-f:+change-preview(bat --color=always {})' \
        --bind='ctrl-f:+refresh-preview' \
        --bind='ctrl-a:select-all' \
        --bind='ctrl-x:deselect-all' \
        --color header:italic \
        --header '
CTRL-D to display directories
CTRL-F to display files
CTRL-A/CTRL-X to select/deselect all
ENTER to edit | DEL to delete
CTRL-P to toggle preview
')

    if [ -d "$selection" ]; then
        cd "$selection" || return
    elif [ -f "$selection" ]; then
        # Change to the directory containing the file
        cd "$(dirname "$selection")" || return
    fi
    # alternatively edit selection via EDITOR
    # else
    #     eval "$EDITOR $selection"
    # fi
}

# Function to pretty-print CSV files
function pretty_csv {
    perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$@" | column -t -s, | bat -S
}

# Function to prevent AWS environment variables from being added to history
function zshaddhistory() {
  if [[ $1 == export\ AWS_* ]]; then
    return 1
  fi
  return 0
}

# Created by `userpath` on 2025-03-12 18:05:14
# export PATH="$PATH:/Users/richardlam/.local/bin:/Users/richardlam/.local/bin"

# BEGIN TopHat's shell integrations
source /Users/richardlam/.tophat/tophat.zsh
# END TopHat's shell integrations
