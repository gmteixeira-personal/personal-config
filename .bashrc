# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Prepend a directory to PATH, once, and only if it exists.
#
# Both checks earn their place. The existence test is what keeps this file
# portable across machines: every tool below is installed per-machine -- bob puts
# nvim under ~/.local/share, the .NET SDK is a ~/.dotnet install on one machine
# and a system package on another -- so a machine that gets one of them from
# /usr must not carry a dead entry for the other layout. The dedupe test keeps
# PATH from growing a second copy of everything each time this file is
# re-sourced.
prepend_path() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
  *":$1:"*) ;;
  *) export PATH="$1:$PATH" ;;
  esac
}

# .NET SDK, when it is a per-user install under ~/.dotnet. DOTNET_ROOT is
# exported only in that case: a system-packaged dotnet locates its own root, and
# naming the wrong directory would override that correct answer.
#
# The test is for the dotnet binary rather than for the directory, because the
# directory is not evidence of anything. A system-packaged dotnet creates
# ~/.dotnet itself on first run, to hold first-use sentinels and a corefx cache
# -- so on a machine with no per-user SDK at all the directory exists, holds no
# runtime, and a -d test would point DOTNET_ROOT straight at it.
#
# Set before the non-interactive early return below so non-interactive shells
# (scripts, tool runners) see dotnet too.
if [ -x "$HOME/.dotnet/dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  prepend_path "$DOTNET_ROOT/tools"
  prepend_path "$DOTNET_ROOT"
fi

# Neovim, when bob installed it rather than the system package manager. Set
# before the non-interactive early return below so scripts and tool runners that
# spawn $EDITOR find it too.
prepend_path "$HOME/.local/share/bob/nvim-bin"
export EDITOR="nvim"
export VISUAL="nvim"

# Rust toolchains installed by rustup, and ~/.local/bin. Both are set before the
# non-interactive early return below, so scripts and tool runners see the tools
# installed there. Cargo is prepended before ~/.local/bin so that directory stays
# ahead of it in PATH, as it was before these entries were guarded.
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.local/bin"

# Neovim for sudoedit. SUDO_EDITOR is read by sudoedit alone and outranks VISUAL
# and EDITOR, so naming it states the choice unambiguously and keeps it immune to
# anything later in a session setting VISUAL for its own purposes.
#
# It carries an absolute path where EDITOR and VISUAL above keep the bare name.
# Those two are read by git, crontab, systemctl edit and everything else that
# spawns an editor, each of which should resolve the name freshly against the
# PATH of the moment; an absolute path there would pin them to whatever existed
# when the shell started. SUDO_EDITOR has one consumer, and sudo documents the
# environment it hands the editor but not the PATH it searches to find it, so a
# bare name would leave the bob-installed case resting on an undocumented detail.
#
# Resolved from PATH rather than from a named directory, and placed after the
# prepends above so it sees them: a bob install and a system package both work
# without this file naming either. No nvim, no variable -- an empty SUDO_EDITOR
# is still consulted and names nothing, where an unset one lets sudoedit fall
# through to VISUAL, then EDITOR, then the editor list in sudoers, as it does
# today. Set before the non-interactive early return below, with EDITOR and
# VISUAL, since all three are read for the same reason.
_nvim_path="$(command -v nvim)"
if [ -n "$_nvim_path" ]; then
  export SUDO_EDITOR="$_nvim_path"
fi
unset _nvim_path

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# OPENSPEC:START
# OpenSpec shell completions configuration
if [ -d "$HOME/.local/share/bash-completion/completions" ]; then
  for f in "$HOME/.local/share/bash-completion/completions"/*; do
    [ -f "$f" ] && . "$f"
  done
fi
# OPENSPEC:END

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # Bright slots named outright, for the same reason as LS_COLORS below:
  # Windows Terminal promotes bold to bright, herdr keeps the normal slot.
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;92m\]\u@\h\[\033[00m\]:\[\033[01;94m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

# Hand the terminal's own cursor shape to every command before it runs.
#
# ~/.inputrc puts readline in vi mode and reports that mode through the cursor,
# a blinking beam while typing. Readline repaints the shape on a mode switch and
# never on hand-off, so a command inherits whatever was showing when Enter was
# pressed -- always the beam, since a fresh prompt starts in insert mode. A
# full-screen program that sets no cursor of its own then runs with the beam for
# its whole session; `claude` is one, its binary carrying no DECSCUSR sequence at
# all, so nothing in it can override what it was handed.
#
# PS0 is printed after the command line is read and before it is executed, which
# is that hand-off. \e[0 q is DECSCUSR "default" rather than a hard-coded block,
# so the shape comes from the terminal profile. Programs that manage their own
# cursor, nvim among them, set theirs after this and are unaffected; the beam
# comes back with the next prompt, so the vi mode indicator still works.
PS0=$'\e[0 q'

# Advertise 24-bit color to programs that ask for it.
#
# Neovim does not need this -- lua/config/options.lua sets 'termguicolors'
# outright -- but nearly everything else gates truecolor on COLORTERM: delta,
# bat, fzf, supports-color in Node, rich in Python. terminfo cannot carry the
# answer, because TERM is xterm-256color and its colors# capability is 256; the
# entries that do declare direct color, xterm-direct among them, are absent on
# remote hosts, and TERM travels over ssh.
#
# Named only where the terminal is known to support it, and never over a value
# something else already set. Exporting it unconditionally would claim truecolor
# on a bare tty and in an ssh session from a terminal that lacks it -- worse than
# saying nothing, because a program that believes the claim emits escapes the
# terminal then draws as literal text.
if [ -z "${COLORTERM:-}" ] && { [ -n "${WT_SESSION:-}" ] ||
  [ -n "${WEZTERM_EXECUTABLE:-}" ] ||
  [ -n "${KITTY_WINDOW_ID:-}" ] ||
  [ "${TERM_PROGRAM:-}" = "vscode" ] ||
  [ "${TERM_PROGRAM:-}" = "iTerm.app" ]; }; then
  export COLORTERM=truecolor
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

  # Ask for the bright palette slots outright instead of relying on the
  # terminal to promote bold to bright. Windows Terminal does that promotion
  # (intenseTextStyle "all"); herdr renders bold as weight and keeps the
  # normal slot, so the same listing came out darker inside herdr.
  LS_COLORS=${LS_COLORS//=01;3/=01;9}

  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# nvm, when it is installed. NVM_DIR is named unconditionally because nvm's own
# installer expects to find it here and rewrites this block if it does not; the
# two guards below are what keep an absent nvm from doing anything.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# direnv, hooked in so the working directory decides which Python virtual
# environment is on PATH. It applies whatever the nearest approved .envrc
# declares and restores the captured environment on the way back out, which is
# what keeps a project's .venv from outliving the directory that declared it.
#
# Driven off PROMPT_COMMAND, which is direnv's own bash hook: bash has no chpwd
# equivalent, and wrapping cd would miss pushd, popd, and zoxide's z -- it calls
# builtin cd and so bypasses a cd function entirely.
#
# Placed after the non-interactive early return far above because it is
# prompt-driven, and a script or tool runner that changes directory should see
# no environment appear or disappear on its behalf. Placed before the exec fish
# below because nothing after that line runs.
#
# The command check is what makes the dependency optional: on a machine without
# direnv there is no hook and no error, and environments are activated by hand
# as they were before this block existed.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Hand interactive sessions to fish, whichever way this distro was entered -- a
# Windows Terminal tab, `wsl -d archlinux` from a cmd or PowerShell prompt, an
# editor's integrated terminal. Doing it here rather than with chsh is what
# keeps /etc/passwd on bash: $SHELL stays /bin/bash, so scripts, `$SHELL -c`,
# sudo -s and every tool runner that assumes POSIX syntax are untouched, and
# only the shell a human types at changes.
#
# Placed last so everything above is already exported into the environment fish
# inherits -- PATH, EDITOR, COLORTERM, the LS_COLORS bright-slot fix. exec
# replaces bash rather than nesting under it, so no idle parent survives and a
# single exit ends the session.
#
# FISH_LAUNCHED is what keeps this from firing twice. A bash started from
# inside fish is still interactive and would otherwise come straight back here;
# with the guard it stays bash, which is what someone dropping to bash on
# purpose wants. The non-interactive early return far above already excludes
# `bash -c`, so nothing scripted reaches this line.
if [ -z "$FISH_LAUNCHED" ] && command -v fish >/dev/null 2>&1; then
  export FISH_LAUNCHED=1
  exec fish
fi
