#!/bin/bash

# Close the transient terminal window this script was launched in.
# Set FZF_EXPLORER_CLOSE_WINDOW=0 to disable this behavior.
close_terminal_window() {
    [ "${FZF_EXPLORER_CLOSE_WINDOW:-1}" = "0" ] && return 0

    local pid comm
    pid="$PPID"

    while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null; do
        comm=$(ps -o comm= -p "$pid" 2>/dev/null | tr -d '[:space:]')
        case "$comm" in
            kitty|kittyd|foot|alacritty|wezterm-gui|gnome-terminal-server|konsole|xfce4-terminal|tilix|xterm|st|urxvt)
                kill -TERM "$pid" >/dev/null 2>&1
                return 0
                ;;
        esac
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d '[:space:]')
    done

    return 0
}

# Define the search directory (defaults to HOME if no argument is passed)
SEARCH_DIR="${1:-$HOME}"

selected=$(cd "$SEARCH_DIR" 2>/dev/null && \
    fd --type d --exclude .git . | \
    awk -F'/' 'BEGIN { OFS="\t" }
        {
            path = $0
            sub(/\/+$/, "", path)

            n = split(path, p, "/")
            dir = p[n]
            if (dir == "") {
                dir = "."
            }

            display_name = " " dir
            printf "%-56s\t%s\n", display_name, path
        }' | \
    fzf \
        --height=100% \
        --layout=reverse \
        --border=none \
        --prompt="Open folder > " \
        --ellipsis="…" \
        --preview='dir={2}; name=$(basename "$dir"); location=$(dirname "$dir"); printf "\033[2;37mFolder:\033[0m \033[37m%s\033[0m\n\033[2;37mLocation:\033[0m \033[37m%s\033[0m\n" "$name" "$location"' \
        --preview-window=right:50%:wrap:noborder \
        --delimiter=$'\t' \
        --with-nth=1 \
        --nth=1,2 \
        --info=hidden)

if [ -n "$selected" ]; then
    rel_path=$(printf '%s' "$selected" | cut -f2-)
    abs_path=$(realpath "$SEARCH_DIR/$rel_path")

    if command -v setsid >/dev/null 2>&1; then
        setsid -f dolphin "$abs_path" >/dev/null 2>&1
    else
        nohup dolphin "$abs_path" >/dev/null 2>&1 < /dev/null &
    fi

    clear
    close_terminal_window
    exit 0
fi

clear
close_terminal_window
exit 0
