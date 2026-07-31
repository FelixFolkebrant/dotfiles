#!/usr/bin/env bash
# Cycle the internal panel through its firmware-advertised refresh modes.
# This Lenovo LEN151WQXGA panel currently exposes 60 and 165 Hz only; 90 Hz is
# kept in the preferred order so it starts working automatically if firmware
# ever advertises it, but no unsupported custom mode is forced.

set -Eeuo pipefail

readonly OUTPUT='eDP-1'
readonly PREFERRED_RATES=(60 90 165)
readonly STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-eDP-1-refresh-rate"

monitors=$(hyprctl monitors all)

if ! grep -q "^Monitor ${OUTPUT} " <<<"$monitors"; then
    printf '%s is not connected\n' "$OUTPUT" >&2
    exit 1
fi

current_mode=$(awk -v output="$OUTPUT" '
    $1 == "Monitor" && $2 == output { getline; print $1; exit }
' <<<"$monitors")
resolution=${current_mode%@*}
current_rate=${current_mode#*@}
current_rate=${current_rate%%.*}
scale=$(awk -v output="$OUTPUT" '
    $1 == "Monitor" && $2 == output { inside = 1; next }
    inside && $1 == "Monitor" { exit }
    inside && $1 == "scale:" { print $2; exit }
' <<<"$monitors")
scale=${scale:-1}

available_modes=$(awk -v output="$OUTPUT" '
    $1 == "Monitor" && $2 == output { inside = 1; next }
    inside && $1 == "Monitor" { exit }
    inside && $1 == "availableModes:" { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }
' <<<"$monitors")

supports_rate() {
    grep -Fq "${resolution}@${1}.00Hz" <<<"$available_modes"
}

current_index=0
for i in "${!PREFERRED_RATES[@]}"; do
    if [[ ${PREFERRED_RATES[$i]} == "$current_rate" ]]; then
        current_index=$i
        break
    fi
done

next_rate=''
for offset in 1 2 3; do
    candidate_index=$(( (current_index + offset) % ${#PREFERRED_RATES[@]} ))
    candidate=${PREFERRED_RATES[$candidate_index]}
    if supports_rate "$candidate"; then
        next_rate=$candidate
        break
    fi
done

if [[ -z $next_rate ]]; then
    printf 'no supported preferred mode for %s\n' "$OUTPUT" >&2
    exit 1
fi

# Hyprland's Lua config is dynamically updated through a reload, rather than
# `hyprctl keyword`. The config reads this session-only state file and retains
# the active power profile's compositor policy while it reloads.
umask 077
printf '%s\n' "$next_rate" > "$STATE_FILE"
if ! hyprctl reload >/dev/null; then
    printf 'Hyprland could not reload its Lua configuration\n' >&2
    exit 1
fi

# A modeset is asynchronous; wait briefly, then verify the rate actually in use.
for _ in 1 2 3 4 5; do
    sleep 0.1
    actual_mode=$(hyprctl monitors all | awk -v output="$OUTPUT" '
        $1 == "Monitor" && $2 == output { getline; print $1; exit }
    ')
    actual_rate=${actual_mode#*@}
    actual_rate=${actual_rate%%.*}
    [[ $actual_rate == "$next_rate" ]] && break
done

if [[ ${actual_rate:-unknown} != "$next_rate" ]]; then
    printf 'requested %s Hz; current rate is %s Hz\n' "$next_rate" "${actual_rate:-unknown}" >&2
    exit 1
fi
