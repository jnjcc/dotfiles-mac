### Solarized-Dark-ansi.terminal: 
###   https://github.com/altercation/solarized
export TERM="xterm"

export CLICOLOR=1
export PS1="\u@\H \w\$ "
export EDITOR="vim"

sudobrew() {
    BREW=`which brew`
    UGRP=$(ls -lh ${BREW} | awk -F' ' '{ print $3":"$4 }')
    sudo chown root:wheel ${BREW}
    sudo brew "$@"
    sudo chown "$UGRP" ${BREW}
}
