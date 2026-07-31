#!/usr/bin/env bash
# Apply the laptop's complete desktop power profile.
#
# The CPU policy is owned by power-profiles-daemon.  On this AMD P-state EPP
# laptop it changes platform_profile, governor and EPP together.  The daemon
# intentionally leaves the kernel's global boost switch enabled; the
# power-saver EPP still strongly de-prioritises boost without a root-only,
# global turbo toggle.

set -u

readonly STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-power-profile"

read_sysfs() {
    local path=$1
    [[ -r $path ]] && cat "$path" || printf 'unavailable'
}

has_discrete_gpu() {
    local gpu_count
    gpu_count=$(lspci -Dnn 2>/dev/null | awk '/(VGA compatible controller|3D controller|Display controller)/ { count++ } END { print count + 0 }')
    (( gpu_count > 1 ))
}

apply_compositor_policy() {
    local profile=$1

    # Lua configs do not support `hyprctl keyword`. The config reads this
    # session-only state during reload, so Fn+R also preserves this policy.
    umask 077
    printf '%s\n' "$profile" > "$STATE_FILE"
    hyprctl reload >/dev/null 2>&1 || true
}

print_status() {
    local profile governor epp boost platform gpu
    profile=$(powerprofilesctl get 2>/dev/null || printf 'unavailable')
    governor=$(read_sysfs /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    epp=$(read_sysfs /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)
    boost=$(read_sysfs /sys/devices/system/cpu/cpufreq/boost)
    platform=$(read_sysfs /sys/firmware/acpi/platform_profile)
    gpu='integrated GPU only'
    has_discrete_gpu && gpu='discrete GPU detected; leave it on runtime-PM/offload mode'

    printf 'profile=%s\nplatform=%s\ngovernor=%s\nepp=%s\nboost=%s\ngpu=%s\n' \
        "$profile" "$platform" "$governor" "$epp" "$boost" "$gpu"
}

case ${1:-toggle} in
    power-saver|balanced|performance)
        target=$1
        ;;
    toggle)
        current=$(powerprofilesctl get 2>/dev/null || printf 'balanced')
        case "$current" in
            performance) target=power-saver ;;
            power-saver|powersave) target=balanced ;;
            *) target=performance ;;
        esac
        ;;
    --status)
        print_status
        exit 0
        ;;
    *)
        printf 'Usage: %s [toggle|power-saver|balanced|performance|--status]\n' "$0" >&2
        exit 2
        ;;
esac

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    printf 'powerprofilesctl is not installed\n' >&2
    exit 1
fi

if ! powerprofilesctl set "$target"; then
    printf 'could not select power profile: %s\n' "$target" >&2
    exit 1
fi

# Brightness and refresh rate remain fully manual. Fn+R is separately handled
# by refresh-rate-toggle.sh.
apply_compositor_policy "$target"
