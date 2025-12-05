# Nushell Environment Config File
#
# version = 0.78.0

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# Editor settings
$env.EDITOR = 'nvim'
$env.VISUAL = 'neovide'
$env.MICRO_TRUECOLOR = 1
$env.COLORTERM = 'truecolor'

$env.HOME = 'C:/Users/6fire'

# Register carapace completers
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

# Add Kroki CLI to PATH
# let-env PATH = ($env.PaTH | split row (char esep) | prepend '~\\programming\\kroki')
$env.Path = ($env.Path | split row (char esep) | prepend '~\\programming\\kroki')

if $env.PWD != 'C:\\Users\\6fire' { cd 'C:\\Users\\6fire' }

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

zoxide init nushell | save -f ~/.zoxide.nu
