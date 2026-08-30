# cd, then list what is there. Autoloaded, as mkcd is.
function cl --description 'cd into a directory and list it'
    cd $argv[1]
    ls -lah
end
