# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/bin:"*) ;;
        *) PATH="$HOME/bin:$PATH" ;;
    esac
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

# .NET SDK, when it is a per-user install under ~/.dotnet. ~/.bashrc does this
# too, for shells that never read this file, and both test for the binary rather
# than for the directory: a system-packaged dotnet creates ~/.dotnet itself to
# hold first-use sentinels, so the directory exists on machines with no per-user
# SDK and would point DOTNET_ROOT at a root holding no runtime. The inner guard
# keeps PATH from growing a duplicate entry.
if [ -x "$HOME/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    case ":$PATH:" in
        *":$DOTNET_ROOT:"*) ;;
        *) export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH" ;;
    esac
fi
