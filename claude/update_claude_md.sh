#!/bin/bash
# update_claude_md.sh
# Actualiza la sección dinámica del CLAUDE.md con info actual del sistema
# Uso: ./update_claude_md.sh
# Opcional en cron: 0 9 * * * /home/roy/update_claude_md.sh

CLAUDE_MD="$HOME/.claude/CLAUDE.md"

# --- Recopilar info del sistema ---
FECHA=$(date '+%Y-%m-%d %H:%M')
PYTHON_VER=$(python3 --version 2>/dev/null || echo "no encontrado")
NODE_VER=$(node --version 2>/dev/null || echo "no encontrado")
NVM_VER=$(nvm --version 2>/dev/null || echo "no encontrado")
DISK_HOME=$(df -h $HOME | awk 'NR==2 {print $3 " usados de " $2 " (" $5 " lleno)"}')
GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader 2>/dev/null || echo "nvidia-smi no disponible")
TMUX_SESSIONS=$(tmux ls 2>/dev/null || echo "ninguna sesión activa")
DOCKER_CONTAINERS=$(docker ps --format "{{.Names}} ({{.Status}})" 2>/dev/null || echo "Docker no activo o sin contenedores")
RCLONE_REMOTES=$(rclone listremotes 2>/dev/null || echo "rclone no disponible")

# Pods activos en RunPod (requiere runpodctl instalado)
RUNPOD_PODS=$(runpodctl get pod 2>/dev/null || echo "runpodctl no instalado o sin pods activos")

# --- Construir bloque dinámico ---
NUEVO_BLOQUE="<!-- AUTO-START -->
_Actualizado automáticamente: $FECHA_

### Sistema actual

\`\`\`
Python     : $PYTHON_VER
Node       : $NODE_VER
nvm        : $NVM_VER
Disco home : $DISK_HOME
GPU local  : $GPU_INFO
\`\`\`

### Sesiones tmux activas
\`\`\`
$TMUX_SESSIONS
\`\`\`

### Contenedores Docker activos
\`\`\`
$DOCKER_CONTAINERS
\`\`\`

### Remotos rclone configurados
\`\`\`
$RCLONE_REMOTES
\`\`\`

### Pods RunPod activos
\`\`\`
$RUNPOD_PODS
\`\`\`
<!-- AUTO-END -->"

# --- Reemplazar bloque entre marcadores ---
# Usa python3 para hacer el reemplazo de forma segura (evita problemas con sed y caracteres especiales)
python3 - <<PYEOF
import re

with open("$CLAUDE_MD", "r") as f:
    contenido = f.read()

nuevo = '''$NUEVO_BLOQUE'''

resultado = re.sub(
    r'<!-- AUTO-START -->.*?<!-- AUTO-END -->',
    nuevo,
    contenido,
    flags=re.DOTALL
)

with open("$CLAUDE_MD", "w") as f:
    f.write(resultado)

print("✅ CLAUDE.md actualizado correctamente.")
PYEOF
