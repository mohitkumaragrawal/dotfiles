local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 12

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

config.scrollback_lines = 90000

return config
