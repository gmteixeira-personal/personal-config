# waybar ships only waybar(5) (the config-file format), no waybar(1), so fish's
# man-page harvester produces nothing. These are derived from `waybar --help`.

complete -c waybar -f
complete -c waybar -s h -l help    -d 'Display usage information'
complete -c waybar -s v -l version -d 'Show version'
complete -c waybar -s c -l config  -r -F -d 'Config path'
complete -c waybar -s s -l style   -r -F -d 'Style path'
complete -c waybar -s b -l bar     -x    -d 'Bar id'
complete -c waybar -s l -l log-level -x -a 'trace debug info warning error critical off' -d 'Log level'
