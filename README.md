# dotfiles — Roy

Configuración personal para Ubuntu. Symlinks gestionados con `install.sh`.

---

## Estructura

```
bash/       .bashrc, .profile
git/        .gitconfig
tmux/       .tmux.conf
wezterm/    wezterm.lua (tema Claude light/dark)
claude/     aliases.sh, close_session.sh, update_claude_md.sh
scripts/    gabinete, laptop, vps_n8n, vps_openclaw
```

---

## Instalación en máquina nueva

```bash
# 1. Clonar el repo
git clone https://github.com/Rafarafa10/dotfiles.git ~/dotfiles

# 2. Instalar symlinks
cd ~/dotfiles && bash install.sh

# 3. Recargar shell
source ~/.bashrc
```

> Los archivos originales se respaldan automáticamente en `~/.dotfiles-backup/` antes de crear cualquier symlink.

---

## Sincronización entre máquinas

El alias `claude` hace `git pull` automático de este repo cada vez que se ejecuta.

Flujo de edición:
```bash
# Editas normalmente (ej: vim ~/.bashrc)
# Los cambios se reflejan en ~/dotfiles/ por los symlinks
cd ~/dotfiles
git add .
git commit -m "descripción del cambio"
git push
# En la otra máquina:
git pull
```

### Máquinas activas
| Nombre | OS | Notas |
|--------|----|-------|
| Laptop (principal) | Ubuntu — HP Laptop 15-da0xxx | Máquina de uso diario |
| Gabinete | Ubuntu | Conectarse y correr install.sh |
| VPS n8n | Linux | Automatizaciones |
| VPS openclaw | Linux | Proyecto en desarrollo |

---

## Programas principales

| Programa | Para qué lo uso |
|----------|----------------|
| WezTerm | Terminal principal con tema claro/oscuro |
| tmux | Sesiones de terminal persistentes |
| Git + GitHub | Control de versiones y respaldo |
| Python 3 | Scripting y aprendizaje de programación |
| NVM | Gestión de versiones de Node.js |
| ComfyUI | Generación de imágenes 4K y video con IA (RunPod + local) |
| Claude (AI) | Asistencia en desarrollo y proyectos |
| n8n | Automatizaciones entre servicios |

---

## Proyectos activos

- **AI Influencer** — Proyecto digital principal, construcción de presencia con IA
- **Betty's Spa Business** — Negocio que apoyo con herramientas digitales

---

## Contexto para IA

> Copia y pega este bloque al inicio de cualquier conversación nueva con Claude u otra IA para que entienda tu setup sin que tengas que explicarlo.

```
Hola. Aquí mi contexto de trabajo:

- Nombre: Roy
- OS: Ubuntu (HP Laptop 15-da0xxx como máquina principal)
- Terminal: WezTerm con tema claro/oscuro personalizado
- Shell: Bash con NVM, aliases personalizados en ~/.claude/scripts/aliases.sh
- Nivel: Aprendiz de programación Python, nuevo en Linux y servicios de IA
- Herramientas: Python 3, Git, GitHub, tmux, ComfyUI, n8n
- Repo de configs: https://github.com/Rafarafa10/dotfiles
- Máquinas: Laptop (principal), Gabinete, VPS n8n, VPS openclaw

Proyectos activos:
1. AI Influencer — proyecto digital principal con IA
2. Betty's Spa Business — negocio que apoyo digitalmente

Prefiero explicaciones claras y paso a paso. Cuando sea relevante, muéstrame comandos de terminal listos para copiar y pegar.
```

---

## Notas de instalación por programa

### WezTerm
- Config en `wezterm/wezterm.lua`
- Tema sigue el modo claro/oscuro del sistema automáticamente
- Instalar WezTerm: https://wezfurlong.org/wezterm/installation.html

### ComfyUI
- **En la nube:** RunPod con pods rentados por sesión (no permanentes)
  - GPUs: RTX 5090 / RTX 4090
  - 2 Persistent Volumes de ~300GB c/u (actualmente pausados para ahorrar costo)
  - Vol 1 — Imágenes: ZImage → img2img → upscale 4K
  - Vol 2 — Video: LTX Video (img2video)
- **Local:** RTX 4060 Ti en gabinete, para pruebas ligeras
- **Backup:** OneDrive vía rclone (~239GB), montado en `/home/roy/mnt/onedrive_q*`
- Para reactivar volumes: abrir RunPod y reconectar los volumes pausados

### NVM
- Ya incluido y limpio en `bash/bashrc`
- Para instalar NVM desde cero: https://github.com/nvm-sh/nvm

---

## Recursos útiles

- [WezTerm docs](https://wezfurlong.org/wezterm/)
- [tmux cheatsheet](https://tmuxcheatsheet.com/)
- [Git basics](https://rogerdudler.github.io/git-guide/index.es.html)
- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [n8n docs](https://docs.n8n.io/)
