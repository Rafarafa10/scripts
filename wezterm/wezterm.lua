local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ══════════════════════════════════════════
-- 🎨 TEMAS: LIGHT (Claude) y DARK (Night)
-- ══════════════════════════════════════════
local themes = {
  light = {
    foreground = '#2D2B28',
    background = '#FAF6F1',
    cursor_bg = '#DA7756',
    cursor_fg = '#FAF6F1',
    cursor_border = '#DA7756',
    selection_bg = '#E8DDD3',
    selection_fg = '#2D2B28',
    split = '#D4C9BD',
    ansi = {
      '#3B3836', '#C4652A', '#6B8E5A', '#B8860B',
      '#5B7B9A', '#8B6B8B', '#5A8A8A', '#D4C9BD',
    },
    brights = {
      '#6B6560', '#DA7756', '#7FA86E', '#D4A843',
      '#7A9DBF', '#A687A6', '#72ABAB', '#FAF6F1',
    },
    tab_bar = {
      background = '#EFE8DF',
      active_tab = { bg_color = '#D4C9BD', fg_color = '#3B3836', intensity = 'Bold' },
      inactive_tab = { bg_color = '#E4DCD2', fg_color = '#6B6560' },
      inactive_tab_hover = { bg_color = '#D9CFC4', fg_color = '#2D2B28' },
      new_tab = { bg_color = '#EFE8DF', fg_color = '#6B6560' },
    },
    -- Pestanas default (sin color asignado)
    tab_active   = { bg = '#D4C9BD', fg = '#2D2B28' },
    tab_inactive = { bg = '#3B3836', fg = '#FFFFFF' },
  },

  dark = {
    foreground = '#E8E4DE',                  -- texto crema claro
    background = '#2B2A27',                  -- fondo oscuro cálido de claude.ai
    cursor_bg = '#DA7756',                   -- cursor terracotta
    cursor_fg = '#2B2A27',
    cursor_border = '#DA7756',
    selection_bg = '#4A4540',                -- selección cálida oscura
    selection_fg = '#E8E4DE',
    split = '#4A4540',
    ansi = {
      '#1E1D1B',   -- negro
      '#DA7756',   -- rojo (terracotta Claude)
      '#9EB87A',   -- verde (oliva claro)
      '#D4A843',   -- amarillo (dorado)
      '#7A9DBF',   -- azul (acero claro)
      '#A687A6',   -- magenta (lavanda)
      '#72ABAB',   -- cyan (teal)
      '#B0A99F',   -- blanco (beige apagado)
    },
    brights = {
      '#6B6560',   -- negro brillante (gris cálido)
      '#E8926E',   -- rojo brillante (naranja claro)
      '#B5D191',   -- verde brillante
      '#E8C56B',   -- amarillo brillante
      '#95B8D6',   -- azul brillante
      '#BFA0BF',   -- magenta brillante
      '#8DC4C4',   -- cyan brillante
      '#F5F0E8',   -- blanco brillante (crema)
    },
    tab_bar = {
      background = '#222120',
      active_tab = { bg_color = '#4A4540', fg_color = '#E8E4DE', intensity = 'Bold' },
      inactive_tab = { bg_color = '#2B2A27', fg_color = '#6B6560' },
      inactive_tab_hover = { bg_color = '#363430', fg_color = '#B0A99F' },
      new_tab = { bg_color = '#222120', fg_color = '#6B6560' },
    },
    -- Pestanas default (sin color asignado)
    tab_active   = { bg = '#4A4540', fg = '#E8E4DE' },
    tab_inactive = { bg = '#222120', fg = '#6B6560' },
  },
}

-- Tema actual (persiste en la sesion)
local current_theme = 'light'

-- Aplica un tema al config
local function apply_theme(theme_name)
  local t = themes[theme_name]
  config.colors = {
    foreground = t.foreground,
    background = t.background,
    cursor_bg = t.cursor_bg,
    cursor_fg = t.cursor_fg,
    cursor_border = t.cursor_border,
    selection_bg = t.selection_bg,
    selection_fg = t.selection_fg,
    split = t.split,
    ansi = t.ansi,
    brights = t.brights,
    tab_bar = t.tab_bar,
  }
end

-- Aplicar tema inicial
apply_theme(current_theme)

-- ══════════════════════════════════════════
-- 🏷️ COLOR DE PESTAÑA POR TAB (Ctrl+Shift+Q)
-- ══════════════════════════════════════════
local tab_colors = {}

wezterm.on('format-tab-title', function(tab)
  local color = tab_colors[tab.tab_id]
  local t = themes[current_theme]

  if color then
    -- Con color asignado: seleccionada = letras negras, no seleccionada = letras blancas
    local fg = tab.is_active and '#2D2B28' or '#FFFFFF'
    return {
      { Background = { Color = color } },
      { Foreground = { Color = fg } },
      { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
      { Text = ' ' .. tab.active_pane.title .. ' ' },
    }
  else
    -- Sin color: usa los defaults del tema actual
    local style = tab.is_active and t.tab_active or t.tab_inactive
    return {
      { Background = { Color = style.bg } },
      { Foreground = { Color = style.fg } },
      { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
      { Text = ' ' .. tab.active_pane.title .. ' ' },
    }
  end
end)

-- ══════════════════════════════════════════
-- 🌓 TOGGLE TEMA (Ctrl+Shift+F5)
-- ══════════════════════════════════════════
wezterm.on('toggle-theme', function(window, pane)
  current_theme = current_theme == 'light' and 'dark' or 'light'
  local t = themes[current_theme]
  local overrides = {
    colors = {
      foreground = t.foreground,
      background = t.background,
      cursor_bg = t.cursor_bg,
      cursor_fg = t.cursor_fg,
      cursor_border = t.cursor_border,
      selection_bg = t.selection_bg,
      selection_fg = t.selection_fg,
      split = t.split,
      ansi = t.ansi,
      brights = t.brights,
      tab_bar = t.tab_bar,
    },
  }
  -- Aplicar a todas las ventanas abiertas
  for _, w in ipairs(wezterm.gui.gui_windows()) do
    w:set_config_overrides(overrides)
  end
end)

-- ══════════════════════════════════════════
-- 🎨 SELECTOR DE COLOR DE PESTANA (Ctrl+Shift+Q)
-- ══════════════════════════════════════════
wezterm.on('pick-tab-color', function(window, pane)
  window:perform_action(
    act.InputSelector {
      title = 'Color de pestana',
      choices = {
        { label = 'Naranja (Claude Code)',  id = '#DA7756' },
        { label = 'Verde (n8n)',            id = '#6B8E5A' },
        { label = 'Rosa (Overclaw)',        id = '#C47A8A' },
        { label = 'Azul (SSH/VPS)',         id = '#5B7B9A' },
        { label = 'Dorado (Scripts)',       id = '#B8860B' },
        { label = 'Lavanda (Misc)',         id = '#8B6B8B' },
        { label = 'Teal (Logs)',            id = '#5A8A8A' },
        { label = 'Reset',                  id = 'reset' },
      },
      action = wezterm.action_callback(function(win, p, id)
        if id then
          local tab_id = win:active_tab():tab_id()
          if id == 'reset' then
            tab_colors[tab_id] = nil
          else
            tab_colors[tab_id] = id
          end
        end
      end),
    },
    pane
  )
end)

-- ══════════════════════════════════════════
-- 🔤 FUENTE Y APARIENCIA
-- ══════════════════════════════════════════
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 12.0
config.line_height = 1.1
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 14, right = 14,
  top = 10, bottom = 10,
}

-- ══════════════════════════════════════════
-- 📑 PESTANAS
-- ══════════════════════════════════════════
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

-- ══════════════════════════════════════════
-- ⌨️ ATAJOS DE TECLADO
-- ══════════════════════════════════════════
config.keys = {
  -- Splits
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- Navegar entre splits (alt + flechas)
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left'  },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up'    },
  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down'  },

  -- Redimensionar splits (alt + shift + flechas)
  { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left',  5 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'UpArrow',    mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up',    5 } },
  { key = 'DownArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down',  5 } },

  -- Pestanas
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = false } },
  { key = 'Tab', mods = 'CTRL',     action = act.ActivateTabRelative(1)  },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- Zoom a un panel
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },

  -- Color de pestana
  { key = 'q', mods = 'CTRL|SHIFT', action = act.EmitEvent 'pick-tab-color' },

  -- Renombrar pestana
  { key = 'r', mods = 'CTRL|SHIFT', action = act.PromptInputLine {
    description = 'Nombre de la pestana:',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }},

  -- Toggle light/dark
  { key = 'F5', mods = 'CTRL|SHIFT', action = act.EmitEvent 'toggle-theme' },

  -- Copiar/pegar
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
}

-- GPU rendering (aprovecha tu RTX 4060 Ti)
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- ══════════════════════════════════════════
-- MISC
-- ══════════════════════════════════════════
config.audible_bell = "Disabled"
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.check_for_updates = false

return config
