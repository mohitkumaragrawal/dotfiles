local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 18
config.color_scheme = "kanagawabones"

config.hide_tab_bar_if_only_one_tab = true

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

config.colors = {
	tab_bar = {
		background = "#1f1f28",
		active_tab = {
			bg_color = "#2d4f67",
			fg_color = "#dcd7ba",
		},
		inactive_tab = {
			bg_color = "#16161d",
			fg_color = "#727169",
		},
	},
}
config.keys = {
  {
    key = 'f',
    mods = 'CMD|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

config.scrollback_lines = 50000
config.window_decorations = 'RESIZE'
config.native_macos_fullscreen_mode = true

return config

