#!/bin/bash
# Aliases compartidos entre máquinas
# Repo: https://github.com/Rafarafa10/dotfiles

claude() {
    git -C ~/dotfiles pull --quiet 2>/dev/null
    local session_name="${1:-cc-gabinete-general}"

    # Extraer dominio del nombre: cc-n8n-proyecto → n8n
    local domain
    domain=$(echo "$session_name" | sed 's/^cc-\([^-]*\)-.*/\1/')
    [ "$domain" = "$session_name" ] && domain="local"

    # Guardar timestamp de inicio para calcular duración
    echo "$(date -Iseconds)" > "/tmp/claude_start_${session_name}"

    if [ -n "$TMUX" ]; then
        local current_session
        current_session=$(tmux display-message -p '#S')
        echo "$session_name" > "/tmp/claude_project_${current_session}"
        echo "$domain" > "/tmp/claude_domain_${current_session}"
        command claude --dangerously-skip-permissions
    elif tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
    else
        echo "$session_name" > "/tmp/claude_project_${session_name}"
        echo "$domain" > "/tmp/claude_domain_${session_name}"
        tmux new-session -s "$session_name" \
            "command claude --dangerously-skip-permissions"
    fi
}

alias comfy="cd ~/ia/comfyui/comfyui && source ../venv/bin/activate && python main.py"
alias sessions-web='bash ~/scripts/sessions-server.sh'
alias crun='bash ~/scripts/claude_run.sh'

# Tailscale on-demand
alias ts='tailscale status'
alias ts-up='sudo systemctl start tailscaled && tailscale up --accept-dns=false --accept-routes=false'
alias ts-down='tailscale down 2>/dev/null; sudo systemctl stop tailscaled'

blackscreen() {
    loginctl lock-session
    sleep 1
    local session_id
    session_id=$(loginctl list-sessions --no-legend | grep seat0 | awk '{print $1}')
    if [ -z "$session_id" ]; then
        echo "⚠️ No se pudo confirmar el bloqueo"
        return 1
    fi
    local locked
    locked=$(loginctl show-session "$session_id" -p LockedHint --value)
    if [ "$locked" = "yes" ]; then
        echo "🔒 Pantalla bloqueada correctamente"
    else
        echo "⚠️ No se pudo confirmar el bloqueo"
    fi
}

bye_tmux() {
    if [ -n "$TMUX" ]; then
        tmux kill-session
    else
        echo "No estás en tmux"
    fi
}

sesiones() {
    local DB="$HOME/sessions-db/sessions.json"
    [ ! -f "$DB" ] && echo "No hay sessions.json" && return 1

    if [ $# -eq 0 ]; then
        # Últimas 10 sesiones
        jq -r 'sort_by(.fin) | reverse | .[:10][] |
            "\(.fin[:10]) | \(.session_name) | \(.nodo) | \(.duracion_min)min | \(.resumen[:50])"' "$DB" \
            | column -t -s'|'
    elif [ "$1" = "buscar" ] && [ -n "$2" ]; then
        local term="$2"
        jq -r --arg t "$term" '
            [.[] | select(
                (.session_name | ascii_downcase | contains($t | ascii_downcase)) or
                (.resumen | ascii_downcase | contains($t | ascii_downcase)) or
                (.tags[]? | ascii_downcase | contains($t | ascii_downcase)) or
                (.proyectos[]? | ascii_downcase | contains($t | ascii_downcase))
            )] | sort_by(.fin) | reverse | .[] |
            "\(.fin[:10]) | \(.session_name) | \(.nodo) | \(.duracion_min)min | \(.resumen[:50])"' "$DB" \
            | column -t -s'|'
    elif [ "$1" = "ver" ] && [ -n "$2" ]; then
        local md="$HOME/sessions-db/sessions/${2}.md"
        [ -f "$md" ] && cat "$md" || echo "No encontrado: $2"
    elif [ "$1" = "copiar" ] && [ -n "$2" ]; then
        local md="$HOME/sessions-db/sessions/${2}.md"
        [ -f "$md" ] && cat "$md" | xclip -selection clipboard && echo "Copiado al clipboard" \
            || echo "No encontrado: $2"
    else
        echo "Uso: sesiones [buscar \"texto\" | ver \"id\" | copiar \"id\"]"
    fi
}

# Selector interactivo de sesiones tmux (local + remotos con "all")
tt() {
    if [ "$1" = "all" ]; then
        local -a all_sessions=()   # "local|session_name" o "ssh_alias|session_name"
        local -a all_display=()    # línea formateada para mostrar
        local idx=1

        # --- Sesiones locales ---
        echo "[gabinete]"
        local local_sessions
        local_sessions=$(tmux ls -F '#{session_name}' 2>/dev/null)
        if [ -n "$local_sessions" ]; then
            while IFS= read -r s; do
                local info
                info=$(tmux ls -F '#{session_name}: #{session_windows} ventanas (#{session_created_string})#{?session_attached, (attached),}' 2>/dev/null | grep "^${s}:")
                printf "  %d) %s\n" "$idx" "$info"
                all_sessions+=("local|${s}")
                idx=$((idx + 1))
            done <<< "$local_sessions"
        else
            echo "  sin sesiones"
        fi
        echo ""

        # --- Sesiones remotas ---
        local nodes="vps-n8n-cc:VPS n8n (claudecode)|vps-n8n:VPS n8n (roy)|openclaw:OpenClaw|laptop:Laptop"
        IFS='|' read -ra entries <<< "$nodes"
        for entry in "${entries[@]}"; do
            local ssh_alias="${entry%%:*}"
            local label="${entry#*:}"
            echo "[${label}]"
            local remote_sessions
            remote_sessions=$(ssh -o ConnectTimeout=3 -o BatchMode=yes "$ssh_alias" 'tmux ls -F "#{session_name}: #{session_windows} ventanas (#{session_created_string})#{?session_attached, (attached),}"' 2>/dev/null)
            if [ -n "$remote_sessions" ]; then
                while IFS= read -r line; do
                    local sess_name="${line%%:*}"
                    printf "  %d) %s\n" "$idx" "$line"
                    all_sessions+=("${ssh_alias}|${sess_name}")
                    idx=$((idx + 1))
                done <<< "$remote_sessions"
            else
                echo "  sin sesiones o nodo inaccesible"
            fi
            echo ""
        done

        if [ ${#all_sessions[@]} -eq 0 ]; then
            echo "No hay sesiones disponibles"
            return 1
        fi

        local max=$((idx - 1))
        echo ""
        read -rp "Selecciona [1-${max}] (Enter para cancelar): " choice

        if [ -z "$choice" ]; then
            return 0
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
            local selected="${all_sessions[$((choice - 1))]}"
            local location="${selected%%|*}"
            local target="${selected#*|}"

            if [ "$location" = "local" ]; then
                if [ -n "$TMUX" ]; then
                    tmux switch-client -t "$target"
                else
                    tmux attach -t "$target"
                fi
            else
                # Remoto: ssh -t para forzar TTY y attach
                ssh -t "$location" "tmux attach -t '$target'"
            fi
        else
            echo "Opción inválida"
            return 1
        fi
        return 0
    fi

    if [ -n "$TMUX" ]; then
        echo "Ya estás dentro de tmux. Usa: tmux switch-client -t <sesión>"
        return 1
    fi

    local sessions
    sessions=$(tmux ls -F '#{session_name}' 2>/dev/null)

    if [ -z "$sessions" ]; then
        echo "No hay sesiones tmux activas"
        return 1
    fi

    echo "Sesiones tmux:"
    echo ""
    local i=1
    while IFS= read -r s; do
        local info
        info=$(tmux ls -F '#{session_name}: #{session_windows} ventanas (#{session_created_string})#{?session_attached, (attached),}' 2>/dev/null | grep "^${s}:")
        printf "  %d) %s\n" "$i" "$info"
        i=$((i + 1))
    done <<< "$sessions"

    echo ""
    read -rp "Selecciona [1-$((i - 1))]: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $((i - 1)) ]; then
        local target
        target=$(echo "$sessions" | sed -n "${choice}p")
        tmux attach -t "$target"
    else
        echo "Opción inválida"
        return 1
    fi
}
