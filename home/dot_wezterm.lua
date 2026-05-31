local wezterm = require("wezterm")
local config = wezterm.config_builder()
local launch_menu = {}
local wsl_domains = wezterm.default_wsl_domains()

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
config.default_prog = { "nu.exe" }
config.font = wezterm.font({
	family = "FantasqueSansM Nerd Font Mono",
})
config.font_size = 16
config.launch_menu = launch_menu

-- WSL setup
for idx, dom in ipairs(wsl_domains) do
	if dom.name == "WSL:Ubuntu" then
		dom.default_prog = { "nu" }
	end
end
config.wsl_domains = wsl_domains

config.use_fancy_tab_bar = false
config.check_for_updates = true

-- Themeing for tabline.
-- Based on lualine.nvim
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		theme = config.color_scheme,
	},
})
tabline.apply_to_config(config)

-- Define workspaces as separate lua files
-- Files live in <wezterm.config_dir>/workspaces
local wsinit = wezterm.plugin.require("https://github.com/JuanraCM/wsinit.wezterm")
-- default keybind uses leader
config.leader = { key = "/", mods = "CTRL", timeout_milliseconds = 1000 }
wsinit.setup()
wsinit.apply_to_config(config)

return config
