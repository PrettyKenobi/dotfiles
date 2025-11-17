local wezterm = require("wezterm")
local config = wezterm.config_builder()
local launch_menu = {}
local wsl_domains = wezterm.default_wsl_domains()

-- Modal (vim-like) keybindings
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.enable_defaults("https://github.com/MLFlexer/modal.wezterm")
-- Default UI Mode
local key_table = require("ui_mode").key_table
local icons = {
	left_seperator = wezterm.nerdfonts.ple_left_half_circle_thick,
	key_hint_seperator = " | ",
	mod_seperator = "-",
}
local hint_colors = {
	key_hint_seperator = "Yellow",
	key = "Green",
	hint = "Red",
	bg = "Black",
	left_bg = "Gray",
}
local mode_colors = { bg = "Red", fg = "Black" }
local status_text = require("ui_mode").get_hint_status_text(icons, hint_colors, mode_colors)
modal.add_mode("UI", key_table, status_text)
modal.apply_to_config(config)

-- Key bindings
config.keys = {
	-- Modal plugin: UI Mode
	{
		key = "u",
		mods = "ALT",
		action = activate_mode("UI"),
	},
}
config.key_tables = modal.key_tables

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	table.insert(launch_menu, {
		label = "Powershell",
		args = { "pwsh.exe", "-NoLogo" },
	})
	table.insert(launch_menu, {
		label = "Nushell",
		args = { "nu.exe" },
	})
end

config.color_scheme = "rose-pine-dawn"
config.default_prog = { "C:/Program Files/nu/bin/nu.exe" }
config.font = wezterm.font("FantasqueSansMono Nerd Font M")
config.launch_menu = launch_menu
config.prefer_to_spawn_tabs = true
config.use_fancy_tab_bar = false

for idx, dom in ipairs(wsl_domains) do
	if dom.name == "WSL:Ubuntu" then
		dom.default_prog = { "nu" }
	end
end

config.wsl_domains = wsl_domains
-- Connect to wezterm-mux-server on WSL
-- `wezterm connect wsl`
-- config.unix_domains = {
--{
--	name = "wsl",
--	serve_command = { "wsl", "wezterm-mux-server", "--daemonize" },
--},
--}
return config
