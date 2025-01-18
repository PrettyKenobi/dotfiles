local wezterm = require("wezterm")
local config = {}
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
config.default_prog = { "C:/Program Files/nu/bin/nu.exe" }
config.font = wezterm.font("OpenDyslexicM Nerd Font Mono")
config.launch_menu = launch_menu

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
