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

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth

# default color scheme
#export LSCOLORS=exfxcxdxbxegedabagacad

export LS_OPTIONS='--color=always'
export CLICOLOR=1
export LSCOLORS=ExGxFxdxCxDxDxhbadExEx

alias grep='grep --color=auto'
alias k='kubectl'
source <(kubectl completion zsh)

complete -C '/usr/local/bin/aws_completer' aws

autoload -U +X bashcompinit && bashcompinit
#complete -o nospace -C /opt/homebrew/bin/terraform terraform
complete -o nospace -C /Users/richardlam/bin/terraform terraform


export REPO_HOME=$HOME/Procurify
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="${HOME}/bin:${PATH}"
export GODEBUG=asyncpreemptoff=1

#alias sd="cd ~ && cd \$(find * -type d 2>/dev/null | fzf )"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --ignore-vcs --hidden'
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border'

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
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
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

#function sd() { cd ~ && cd $(find * -type d 2>/dev/null | fzf) }

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

alias lvl='echo "shell level: " $SHLVL'
