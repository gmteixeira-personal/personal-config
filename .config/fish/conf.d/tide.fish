# Tide prompt overrides. Tide's configure wizard stores its answers as
# universal variables in fish_variables, which is gitignored as volatile
# state -- anything set there silently outlives this repository. Settings
# changed by hand therefore live here as globals, which fish prefers over
# a universal of the same name, so this file wins on every machine.

# Prompt character in vi normal (default) mode: quadrant diagonal.
set -g tide_character_vi_icon_default ▚
