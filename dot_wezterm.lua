local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- Plugins
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

-- Resurrect: save to a predictable location and auto-save every 15 minutes
local resurrect_dir = wezterm.home_dir .. "/.local/share/wezterm/resurrect"
os.execute("mkdir -p " .. resurrect_dir)
resurrect.state_manager.change_state_save_dir(resurrect_dir .. "/")
resurrect.state_manager.periodic_save()

-- Unix domain multiplexing: keeps tabs/panes alive when window is closed
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }

-- Font configuration
config.font = wezterm.font("Lilex Nerd Font Mono")
config.font_size = 18.0

-- Performance
config.max_fps = 120

-- Kitty keyboard protocol: enables key combos neovim can't otherwise see
config.enable_kitty_keyboard = true

-- Scrollback
config.scrollback_lines = 10000

-- Transparent background
config.window_background_opacity = 0.75
config.macos_window_background_blur = 9

-- Color scheme
config.color_scheme = "Monokai Remastered"

-- Remove window title bar (keeps resize handles)
config.window_decorations = "RESIZE"

-- Window padding
config.window_padding = { left = 2, right = 2, top = 2, bottom = 2 }

-- Hide tab bar when only one tab is open
config.hide_tab_bar_if_only_one_tab = true

-- Dim inactive panes
config.inactive_pane_hsb = { saturation = 0.6, brightness = 0.3 }

-- Pane border color
config.colors = { split = "#FFD700" }

-- Cmd+Click to open links (iTerm2 style)
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.mouse_bindings = {
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CMD", action = act.OpenLinkAtMouseCursor },
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = act.Nop },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Cell") },
	{ event = { Drag = { streak = 1, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Cell") },
}

-- Point workspace switcher at mise-managed zoxide (WezTerm doesn't run shell init)
workspace_switcher.zoxide_path = wezterm.home_dir .. "/.local/share/mise/shims/zoxide"

-- Workspace formatter: italic yellow with icon
workspace_switcher.workspace_formatter = function(label)
	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Foreground = { AnsiColor = "Yellow" } },
		{ Text = "󱂬 " .. label },
	})
end

-- Resurrect: save state when switching workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
end)

-- Status bar: show current workspace name on the right
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(wezterm.format({
		{ Attribute = { Bold = true } },
		{ Foreground = { AnsiColor = "Yellow" } },
		{ Text = "󱂬 " .. window:active_workspace() .. "  " },
	}))
end)

-- Auto-restore last workspace on startup
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	resurrect.workspace_state.restore_workspace(
		resurrect.state_manager.load_state(window:active_workspace(), "workspace"),
		{
			window = window:gui_window(),
			relative = true,
			restore_text = true,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		}
	)
end)

-- Notify on config reload
wezterm.on("window-config-reloaded", function(window, pane)
	window:toast_notification("WezTerm", "Configuration reloaded!", nil, 4000)
end)

config.keys = {
	-- Reload config
	{ key = "r", mods = "CMD|SHIFT", action = act.ReloadConfiguration },

	-- Split panes (iTerm2 style)
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Close current pane
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	-- Swap pane with another
	{ key = "m", mods = "CMD|SHIFT", action = act.PaneSelect({ mode = "SwapWithActive" }) },

	-- Shift+Enter sends newline for multiline prompts
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

	-- Run make apply in new tab and close when done
	{
		key = "r",
		mods = "CMD|ALT",
		action = act.SpawnCommandInNewTab({
			args = { "zsh", "-i", "-c", "cd ~/code/dotfiles && make apply; exit" },
		}),
	},

	-- Workspace switching
	{ key = "s", mods = "ALT", action = workspace_switcher.switch_workspace() },
	{ key = "p", mods = "ALT", action = workspace_switcher.switch_to_prev_workspace() },

	-- Resurrect: manual save/restore
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			win:toast_notification("WezTerm", "Workspace saved", nil, 4000)
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)")
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
					win:toast_notification("WezTerm", "Restored: " .. label, nil, 4000)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(state, opts)
					win:toast_notification("WezTerm", "Restored: " .. label, nil, 4000)
				end
			end)
		end),
	},
}

-- Smart splits: must be called AFTER config.keys is defined so it appends rather than being overwritten
smart_splits.apply_to_config(config, {
	direction_keys = { "h", "j", "k", "l" },
	modifiers = {
		move = "CTRL",
		resize = "META",
	},
})

return config
