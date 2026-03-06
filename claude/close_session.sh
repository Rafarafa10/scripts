#!/bin/bash
# close_session.sh
# Registra cierre de sesión en bitácora y actualiza sistema
# Uso: close_session.sh "resumen de la sesión" "proyecto1, proyecto2"

RESUMEN="${1:-Sin resumen proporcionado}"
PROYECTOS="${2:-No especificados}"
BITACORA="$HOME/bitacora.md"
FECHA=$(date '+%Y-%m-%d %H:%M')

# --- Crear bitácora si no existe ---
if [ ! -f "$BITACORA" ]; then
    cat > "$BITACORA" << 'HEADER'
# Bitácora de sesiones — Claude Code

Registro automático de cada sesión cerrada con "cierra sesión".

---

HEADER
fi

# --- Append entrada ---
cat >> "$BITACORA" << EOF
### $FECHA

**Resumen:** $RESUMEN

**Proyectos tocados:** $PROYECTOS

---

EOF

# --- Actualizar info del sistema ---
if [ -x "$HOME/update_claude_md.sh" ]; then
    bash "$HOME/update_claude_md.sh"
fi

echo "Sesión registrada en $BITACORA"

# --- Matar sesión tmux ---
if [ -n "$TMUX" ]; then
    tmux kill-session
fi
