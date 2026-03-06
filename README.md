# dotfiles

Configuracion personal para Ubuntu. Symlinks gestionados con `install.sh`.

## Estructura

```
bash/       .bashrc, .profile
git/        .gitconfig
tmux/       .tmux.conf
wezterm/    wezterm.lua (tema Claude light/dark)
claude/     aliases.sh, close_session.sh, update_claude_md.sh
scripts/    gabinete, laptop, vps_n8n, vps_openclaw
```

## Instalacion

```bash
git clone https://github.com/Rafarafa10/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
source ~/.bashrc
```

## Sincronizacion entre maquinas

El alias `claude` hace `git pull` automatico de este repo cada vez que se ejecuta.
Para propagar cambios: editar archivos, commit, push desde cualquier maquina.
