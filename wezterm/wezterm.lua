local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
config.window_background_opacity = 0.60
config.win32_system_backdrop = 'Acrylic'

config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font 'JetBrains Mono'
config.tab_bar_at_bottom = true

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
  options = {
    icons_enabled = true,
    tabs_enabled = true,
    section_separators = {
      left  = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left  = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left  = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { ' 󰚄  '  },
    tabline_b = {  },

    -- tabline_c = { ' ' },  -- filler so the tabs in the middle

    -- tabs themselves
    tab_active = {
      'index',
      { 'parent', padding = 0 },
      '/',
      { 'cwd', padding = { left = 0, right = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },

    -- right side: only show ram + cpu, omit datetime, domain, battery
    tabline_x = { 'ram', 'cpu' },
    tabline_y = {  },
    tabline_z = {  },
  },
})

tabline.apply_to_config(config)

config.disable_default_key_bindings = true

config.keys = {
  {
    key = "t",
    mods = "CTRL|ALT",
    action = wezterm.action.SpawnTab "CurrentPaneDomain",
  },

  {
    key = "w",
    mods = "CTRL|ALT",
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },

  { key = "1", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CTRL|ALT", action = wezterm.action.ActivateTab(-1) },

  {
    key = "Tab",
    mods = "CTRL|ALT",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "PageDown",
    mods = "CTRL|ALT",
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = "PageUp",
    mods = "CTRL|ALT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "Tab",
    mods = "CTRL|ALT|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
}

config.window_close_confirmation = "NeverPrompt"

return config
