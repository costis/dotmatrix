# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return
#[[ $TERM != screen* ]] && exec tmux -2

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias less='less -R'
alias tmux='tmux -2'
alias be='bundle exec'

# easy open
function o { xdg-open "$@";}

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
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# enable antialising for Java Swing apps
# export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=setting'

# Editor, Browser etc
export EDITOR=vim
export BROWSER=/usr/bin/google-chrome

# Vim needs this to show pretty colors
#export TERM=xterm-256color

bind -m vi-insert "C-l":clear-screen

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

PATH=$PATH:/usr/local/lib/jdk1.6.0_33/bin
PATH=~/bin:$PATH

export JAVA_HOME=/usr/local/lib/jdk1.6.0_33

git_has_stash() {
  if [[ -n $(git stash list 2> /dev/null) ]]; then
    echo "★"
  else
    echo ""
  fi
}

git_dirty() {
  st=$(git status 2>/dev/null | tail -n 1)
  if [[ $st != "nothing to commit, working directory clean" ]]; then
    echo " ✗"
  else
    echo " ✓"
  fi
}

get_git_branch() {
  local br=$(git branch 2> /dev/null | grep "*" | sed 's/* //g')
  [ -n "$br" ] && echo "[@$br$(git_has_stash)$(git_dirty)]"
}

export PS1='\u@\h:\w\[\033[34m\]$(get_git_branch)\[\033[0m\]$ '

# for node.js runtime
. ~/nvm/nvm.sh

# Load env vars with credentials for web apps
if [ -f ~/.dev_vars ]; then
    . ~/.dev_vars
fi

# export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
# export LESS=' -R '

# Easily switch to project directories
function cpd() {
  if (( $# > 0 )); then
    folders=($(find ~/projects -type d -name *$1* -maxdepth 1))
    if [ ${#folders[@]} -eq 1  ]; then
      pushd ${folders[0]} 1> /dev/null
    elif [ ${#folders[@]} -eq 0 ]; then
      folders=($(find ~/projects -type d -maxdepth 1))
    fi
  else
    folders=($(find ~/projects -type d -maxdepth 1))
  fi

  while [ ${#folders[@]} -gt 1 ]; do
    # display a selection menu
    i=0
    for f in ${folders[@]}; do
      echo " " $i - ${f##*/}
      ((i++))
    done
    read -p "Select project: " user_input

    # selection by number?
    if [[ $user_input =~ ^[0-9]+$ ]]; then
      d=${folders[$user_input]}
      pushd ~/projects/${d##*/} 1> /dev/null
      break
    # user has entered a string. Search again.
    else
      folders=($(find ~/projects -name *$user_input* -type d -maxdepth 1))
      if [[ ${#folders[@]} -eq 1 ]]; then
        pushd ${folders[0]} 1> /dev/null
        break
      fi
    fi
  done

  return 0
}

# Bash Vi mode
set -o vi
# ^l clear screen
bind -m vi-insert "\C-l":clear-screen

# ^p check for partial match in history
bind -m vi-insert "\C-p":previous-history

# ^n cycle through the list of partial matches
bind -m vi-insert "\C-n":next-history

# bind -m vi-insert "\C-p":dynamic-complete-history
# bind -m vi-insert "\C-n":menu-complete

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Rbenv setup
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
