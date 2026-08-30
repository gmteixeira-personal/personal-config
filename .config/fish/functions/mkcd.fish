# Create a directory and enter it. Autoloaded: fish reads this file the first
# time the name is used, so a session that never calls it never defines it, and
# no interactivity guard is needed -- nothing non-interactive calls it.
function mkcd --description 'Create a directory and cd into it'
    mkdir -p $argv[1]
    cd $argv[1]
end
