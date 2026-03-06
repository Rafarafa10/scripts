#!/bin/bash
# Aliases compartidos entre máquinas
# Repo: https://github.com/Rafarafa10/dotfiles

claude() {
    git -C ~/dotfiles pull --quiet 2>/dev/null
    if [ -n "$TMUX" ]; then
        command claude --dangerously-skip-permissions "$@"
    else
        tmux new-session -A -s claude "claude --dangerously-skip-permissions $*"
    fi
}
alias comfy="cd ~/ia/comfyui/comfyui && source ../venv/bin/activate && python main.py"

bye_tmux() {
    if [ -n "$TMUX" ]; then
        tmux kill-session
    else
        echo "No estás en tmux"
    fi
}
