local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
config.window_background_opacity = 0.60
config.win32_system_backdrop = "Acrylic"

config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.window_decorations = "RESIZE"
config.color_scheme = "Tokyo Night"
config.colors = {
	background = "#091A4C",
}
config.font = wezterm.font("Agave Nerd Font")
config.font_size = 14
config.tab_bar_at_bottom = true

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
	options = {
		icons_enabled = true,
		tabs_enabled = true,
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { " 󰚄  " },
		tabline_b = {},

		tabline_c = { " " }, -- filler so the tabs in the middle

		tab_active = {
			"index",
			{ "tab", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "tab" },

		tabline_x = { "ram", "cpu" },
		tabline_y = {},
		tabline_z = {},
	},
})

tabline.apply_to_config(config)

config.keys = {
	{
		key = "r",
		mods = "CTRL|ALT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	{
		key = "t",
		mods = "CTRL|ALT",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},

	{
		key = "w",
		mods = "CTRL|ALT",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
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

	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },

	{
		key = "UpArrow",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "DownArrow",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "RightArrow",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	{ key = "w", mods = "CTRL|ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
}

config.window_close_confirmation = "NeverPrompt"

return config
