#!/bin/bash
# Herdr tab-bar status. Icons are Nerd Font glyphs (branch/worktree/hdd/battery/
# bolt/clock), so the tab bar needs a patched font.
# Runs every 5s with a 2s timeout, so every probe here
# must be a single cheap syscall-ish command. No network, no subshell loops.

get_git() {
    local branch dirs icon=""
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
    [ -n "$branch" ] || return
    # A linked worktree's git dir is <common>/worktrees/<name>, so the two paths
    # differ. In the main worktree both print the same thing.
    dirs=$(git rev-parse --git-dir --git-common-dir 2>/dev/null)
    [ "$(echo "$dirs" | head -1)" != "$(echo "$dirs" | tail -1)" ] && icon=""
    echo "$icon $branch"
}

get_disk() {
    df -h / 2>/dev/null | awk 'NR==2{print " " $4 " free"}'
}


parts=()
for probe in get_git get_disk; do
    out=$("$probe" 2>/dev/null | tr -d '\n')
    [ -n "$out" ] && parts+=("$out")
done

# join with " | "
out=""
for p in "${parts[@]}"; do
    [ -n "$out" ] && out="$out | "
    out="$out$p"
done
echo "$out"
