# npx(1) is prose-only with no OPTIONS section, so fish's man-page harvester
# generates nothing for it. Flags below come from `npx --help` (npm exec).

function __fish_npx_local_bins
    # Executables exposed by the project's installed dependencies.
    set -l dir (pwd)
    while test "$dir" != /
        if test -d "$dir/node_modules/.bin"
            for f in "$dir"/node_modules/.bin/*
                test -x "$f"; and basename "$f"
            end
            return
        end
        set dir (dirname "$dir")
    end
end

complete -c npx -f
complete -c npx -n __fish_is_first_arg -a '(__fish_npx_local_bins)' -d 'local bin'

complete -c npx -l package -x -d 'Package to make available (repeatable)'
complete -c npx -s c -l call -x -d 'Run a command string via the shell'
complete -c npx -s w -l workspace -x -d 'Run in a named workspace (repeatable)'
complete -c npx -l workspaces -d 'Run in every configured workspace'
complete -c npx -l include-workspace-root -d 'Include the workspace root'
complete -c npx -s y -l yes -d 'Install missing packages without prompting'
complete -c npx -l no -d 'Never install; fail if a package is missing'
