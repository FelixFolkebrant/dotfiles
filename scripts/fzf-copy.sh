#!/bin/bash

# Close the transient terminal window this script was launched in.
# Set FZF_COPY_CLOSE_WINDOW=0 to disable this behavior.
close_terminal_window() {
    [ "${FZF_COPY_CLOSE_WINDOW:-1}" = "0" ] && return 0

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


# 2. Define the search directory (defaults to HOME if no argument is passed)
SEARCH_DIR="${1:-$HOME}"

# 2.1 File extensions to ignore in search results.
# Override with: FZF_COPY_IGNORE_EXTENSIONS="log tmp lock ..."
DEFAULT_IGNORED_EXTENSIONS="log tmp lock bak"
IFS=' ' read -r -a IGNORED_EXTENSIONS <<< "${FZF_COPY_IGNORE_EXTENSIONS:-$DEFAULT_IGNORED_EXTENSIONS}"

# Set to 1 to skip files without an extension (e.g. LICENSE, Makefile).
IGNORE_NO_EXTENSION="${FZF_COPY_IGNORE_NO_EXTENSION:-1}"

# Extension to icon map (single nerd-font glyph per extension).
# Override with: FZF_COPY_ICON_MAP="sh= py= ts= json="
DEFAULT_ICON_MAP="sh= bash= zsh= py= js= ts= json= yml= yaml= toml= md= pdf= zip= tar= gz= log= lock= bak="
ICON_MAP="${FZF_COPY_ICON_MAP:-$DEFAULT_ICON_MAP}"

fd_args=(--type f --hidden --exclude .git .)
for ext in "${IGNORED_EXTENSIONS[@]}"; do
    [ -n "$ext" ] || continue
    fd_args+=(--exclude "*.${ext#.}")
done

# 3. Find files using fd and pipe to fzf
# --hidden includes hidden files, --exclude ignores .git to keep it fast
# Display: icon + filename only. Hidden field keeps full relative path.
selected=$(cd "$SEARCH_DIR" 2>/dev/null && \
    fd "${fd_args[@]}" | \
    awk -F'/' -v ignore_no_ext="$IGNORE_NO_EXTENSION" -v icon_map="$ICON_MAP" 'BEGIN {
            OFS="\t"
            split(icon_map, pairs, " ")
            for (i in pairs) {
                split(pairs[i], kv, "=")
                if (length(kv[1]) > 0 && length(kv[2]) > 0) {
                    icons[tolower(kv[1])] = kv[2]
                }
            }
        }
        {
            n = split($0, p, "/")
            file = p[n]

            ext = ""
            if (match(file, /^.+\.([^.]+)$/, m)) {
                ext = tolower(m[1])
            }

            if (ignore_no_ext == 1 && ext == "") {
                next
            }

            icon = (ext in icons) ? icons[ext] : " "
            display_name = icon " " file
            printf "%-56s\t%s\n", display_name, $0
        }' | \
    fzf \
        --height=100% \
        --layout=reverse \
        --border=none \
        --ellipsis="…" \
        --preview='file={2}; name=$(basename "$file"); location=$(dirname "$file"); printf "\033[2;37mName:\033[0m \033[37m%s\033[0m\n\033[2;37mLocation:\033[0m \033[37m%s\033[0m\n" "$name" "$location"' \
        --preview-window=right:50%:wrap:noborder \
        --delimiter=$'\t' \
        --with-nth=1 \
        --nth=1 \
        --info=hidden)

# 4. Process the selection
if [ -n "$selected" ]; then
    rel_path=$(printf '%s' "$selected" | cut -f2-)

    # Get the absolute path required for the URI list
    abs_path=$(realpath "$SEARCH_DIR/$rel_path")
    
    # Copy to Wayland clipboard using the text/uri-list MIME type
    echo -n "file://$abs_path" | wl-copy -t text/uri-list
    
    # Send a quick desktop notification
    clear
    close_terminal_window
    exit 0
fi

clear
close_terminal_window
exit 0