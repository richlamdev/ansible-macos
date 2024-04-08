# https://dev.to/cassidoo/customizing-my-zsh-prompt-3417
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
autoload -Uz colors
colors

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

autoload -Uz compinit
compinit

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST

PROMPT='%{$fg[blue]%}%n%{$reset_color%}@%{$fg[red]%}%m %{$fg[green]%}|${vcs_info_msg_0_}%{$fg[yellow]%}%~ %{$reset_color%}%% '

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE

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

autoload -U +X bashcompinit && bashcompinit

# kubectl
alias k='kubectl'
source <(kubectl completion zsh)
alias kgs='f() { kubectl get secret $1 -o json | jq ".data | map_values(@base64d)" };f'

# velero
source <(velero completion zsh)
alias v=velero
complete -F __start_velero v

# aws
complete -C '/usr/local/bin/aws_completer' aws

# terraform
complete -o nospace -C /Users/richardlam/bin/terraform terraform

export REPO_HOME=$HOME/Procurify
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="${HOME}/bin:${PATH}"
export GODEBUG=asyncpreemptoff=1
alias lvl='echo "shell level: " $SHLVL'

# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border'

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
  --header 'Press CTRL-Y to copy command into clipboard'"

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

    selection=$(find "$search_folder" -type d \( -name "Library" -o -name "Music" -o -name "Movies" \) -prune -o -print | fzf --multi --height=80% --border=sharp \
        --preview='tree -C {}' --preview-window='50%,border-sharp' \
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
        --header '
        CTRL-D to display directories | CTRL-F to display files
        CTRL-A to select all | CTRL-x to deselect all
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

function pretty_csv {
    perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$@" | column -t -s, | bat -S
}

