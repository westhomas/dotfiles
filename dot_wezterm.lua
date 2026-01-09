local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font("Lilex Nerd Font Mono")
config.font_size = 14.0

-- Transparent background
config.window_background_opacity = 0.75

-- Optional: blur background (macOS only)
config.macos_window_background_blur = 2

-- Color scheme (optional, adjust to your preference)
config.color_scheme = "Monokai"

-- Window padding
config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}

return config
