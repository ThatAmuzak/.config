local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.window_background_opacity = 0.5
config.window_decorations = "RESIZE"

-- config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
config.default_domain = "WSL:NixOS"
config.win32_system_backdrop = "Acrylic"
config.enable_tab_bar = false
config.font = wezterm.font("JetBrains Mono")
return config
