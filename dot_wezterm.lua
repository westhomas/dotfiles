local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.unix_domains = {
	{
		name = "unix",
	},
}

-- This causes `wezterm` to act as though it was started as
-- `wezterm connect unix` by default, connecting to the unix
-- domain on startup.
-- If you prefer to connect manually, leave out this line.
config.default_gui_startup_args = { "connect", "unix" }

-- Font configuration
config.font = wezterm.font("Lilex Nerd Font Mono")
config.font_size = 14.0

-- Transparent background
config.window_background_opacity = 0.75

-- Optional: blur background (macOS only)
config.macos_window_background_blur = 9

-- Color scheme (optional, adjust to your preference)
config.color_scheme = "Monokai"

-- Remove window title bar (keeps resize handles)
config.window_decorations = "RESIZE"

-- Window padding
config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}

-- iTerm2-style keybindings
config.keys = {
	-- Split panes (iTerm2 style)
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Close current pane instead of tab
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	-- Run make apply in new tab and close when done
	{
		key = "a",
		mods = "CMD|ALT",
		action = act.SpawnCommandInNewTab({
			args = { "zsh", "-i", "-c", "cd ~/code/dotfiles && make apply; exit" },
		}),
	},
}

return config
