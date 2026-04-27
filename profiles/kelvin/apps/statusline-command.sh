#!/usr/bin/env bash
# Claude Code statusline. Invoked via programs.claude-code.settings.statusLine.
# Adds a [kae:<first-8>] segment when running inside a kaether kagent sandbox
# (KAETHER_SESSION_ID exported by the container entrypoint). Inert on the host.
input=$(cat)
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$current_dir")

git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            git_info=" (${branch}*)"
        else
            git_info=" (${branch})"
        fi
    fi
fi

kae_info=""
if [[ -n "$KAETHER_SESSION_ID" ]]; then
    kae_info=" [kae:${KAETHER_SESSION_ID:0:8}]"
fi

user=$(whoami)
host=$(hostname -s)
now=$(date +%H:%M)

# Compact model: "Opus 4.7 (1M context)" -> "opus[1m]"; "Sonnet 4.6" -> "sonnet".
short_model=$(echo "$model_name" | awk '{print tolower($1)}')
if echo "$model_name" | grep -q "1M context"; then
    short_model="${short_model}[1m]"
fi

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_str=""
if [[ -n "$cost" && "$cost" != "null" ]]; then
    cost_str=$(printf " | \$%.4f" "$cost")
fi

printf "%s | %s@%s:\033[36m%s\033[0m%s%s | %s%s" \
    "$now" "$user" "$host" "$dir_name" "$git_info" "$kae_info" "$short_model" "$cost_str"
