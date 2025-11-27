# https://github.com/mrzool/bash-sensible/blob/master/sensible.bash

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Perform file completion in a case insensitive fashion
bind "set completion-ignore-case on"

# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

# history
# Undocumented feature which sets the size to "unlimited".
# https://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT='%F %T '
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
export HISTCONTROL=erasedups:ignoreboth
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear" # Don't record some commands
# Show return code if non-zero & continuously update .bash_history & shell
# https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
export PROMPT_COMMAND='ret=$?; if [ $ret -ne 0 ] ; then echo -e "returned \033[01;31m$ret\033[00;00m"; fi;history -a; history -c; history -r'
shopt -s histappend # append to .bash_history instead of overwriting; useful for multiple terms
shopt -s cmdhist # Save multi-line commands as one command

maybe_prepend_path() {
    prepend="$1"
    echo $PATH | grep -q $prepend || export PATH=$prepend:$PATH
}

maybe_append_path() {
    append="$1"
    echo $PATH | grep -q $append || export PATH=$PATH:$append
}

maybe_append_path ~/bin
maybe_append_path /opt/homebrew/opt/postgresql@17/bin
#maybe_prepend_path /usr/local/bin
# homebrew arm64
maybe_prepend_path /opt/homebrew/bin
maybe_prepend_path /opt/homebrew/sbin

export SHELL_ARCH=$(arch | sed -e 's/.*86/x86/')

if [ $SHELL_ARCH = 'arm64' ]; then
    BREW_PREFIX=/opt/homebrew
else
    BREW_PREFIX=/usr/local
fi
eval $(${BREW_PREFIX}/bin/brew shellenv)

alias ibrew='arch -x86_64 /usr/local/bin/brew'
alias mbrew='arch -arm64 /opt/homebrew/bin/brew'

HOMEBREW_API_TOKEN_FILE=~/.homebrew.github.api.token
if test -f "$HOMEBREW_API_TOKEN_FILE"; then
    export HOMEBREW_GITHUB_API_TOKEN=$(<$HOMEBREW_API_TOKEN_FILE)
fi

relink_brew() {
    brew list -1 | while read line; do brew unlink $line; brew link $line; done
}

# latex
eval "$(/usr/libexec/path_helper)"

# elp, etc.
export PATH="~/.local/bin:$PATH"

# emacs
export PATH=/Applications/Emacs.app/Contents/MacOS:$PATH
export EDITOR='emacs -q -nw' # for commits, etc.

pycd () {
    pushd `echo "import os.path; print os.path.dirname(__import__('$1').__file__)" | python`; 
}

alias cd=pushd
alias po=popd
alias ls="ls -G -F"
alias ll="ls -lah"
alias la="ls -a"
alias lr="ls -tr"
alias du="du -h"
alias df="df -h"
alias rs="rsync -avPW"

red='\[\033[0;31m\]'
redb='\[\033[1;31m\]'
green='\[\033[0;32m\]'
greenb='\[\033[1;32m\]'
yellow='\[\033[0;33m\]'
yellowb='\[\033[1;33m\]'
blue='\[\033[0;34m\]'
blueb='\[\033[1;34m\]'
magenta='\[\033[0;35m\]'
magentab='\[\033[1;35m\]'
cyan='\[\033[0;36m\]'
cyanb='\[\033[1;36m\]'
black='\[\033[0m\]'

at_color=$black
host_color=$greenb
cwd_color=$black
arch=$(echo `arch` | grep -q 'i386' && echo '(x86)' || echo '')

if [ $UID -eq 0 ]
then
    user_color=$redb
    PS1="$arch$user_color\u$at_color@$host_color\h$cwd_color:\w$normal# "
else
    user_color=$greenb
    PS1="$arch$user_color\u$at_color@$host_color\h$cwd_color:\w$normal\n\$ "
fi

# keep passphrases in memory, accessible from all shells
# keychain ~/.ssh/id_rsa
# . ~/.keychain/${HOSTNAME}-sh

# which process is on port 8080?
#'lsof -w -n -i tcp:8080' or 'fuser -n tcp 8080' or 'netstat -anp|grep :8080[[:blank:]]'

# example of running multiple sudo commands
#sudo -- sh -c 'whoami; whoami'

#export SSL_CERT_FILE=~/prev/.cacert.pem

#ulimit -n 2560
ulimit -n 131072
ulimit -c unlimited # enable core dumps

alias processes-on-port="netstat -tulpn" # linux

# git
git-current-branch() {
    git branch --no-color | grep \* | cut -d ' ' -f2-
}
git-log-compact() {
    git log --pretty=oneline --abbrev-commit
}

# shell_history for OTP 20+
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 1024000"

export COUCHAUTH=jaydoane:Hpur6joh4pD1GOrJbGij

# for docker
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export LANG=en_US.UTF-8
    # kerl_deactivate
fi

# couchdb elixir tests
mix_test_dev_cluster() {
    (cd ~/proj/couchdb/test/elixir && \
         mix test --trace --exclude without_quorum_test \
             --exclude with_quorum_test --exclude delayed_commits_test)
}

backup-home() {
    rsync -avPW --exclude Library/Containers/com.docker.docker --exclude Library/Caches/Google/Chrome/Default/Cache ~/ /Volumes/Mac\ 500GB/Users/jay/
}

sync-mac() {
    rsync -avPW --files-from=$HOME/.sync-files ~ /Volumes/jay/backup-2021-macbook-pro
}

function sync-home() {
    rsync -avPW \
          --exclude Library/Caches/Google/Chrome/Default/Cache \
          --exclude "Pictures/Photos Library.photoslibrary" \
          ~/ \
          /Volumes/jay/mbp-jay
}

[ -f ~/.bashrc-cloudant ] && . ~/.bashrc-cloudant

[ -f ~/.env ] && . ~/.env

# Needed for gpg signing
export GPG_TTY=$(tty)

# https://starship.rs/guide/#%F0%9F%9A%80-installation
command -v starship &> /dev/null && eval "$(starship init bash)"

. "$HOME/.cargo/env"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/jay/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

#eval "$(/opt/homebrew/bin/mise activate bash)"
