### Solarized-Dark-ansi.terminal: 
###   https://github.com/altercation/solarized
export TERM="xterm"

export CLICOLOR=1
export PS1="\u@\H \w\$ "
## A colored PS1
# export PS1="\[\e[36m\]\u@\[\e[35m\]\H:\[\e[33m\]\w\[\e[0m\]\$ "
export EDITOR="vim"

export TZ=":Pacific/Auckland"

sudobrew() {
    BREW=`which brew`
    UGRP=$(ls -lh ${BREW} | awk -F' ' '{ print $3":"$4 }')
    sudo chown root:wheel ${BREW}
    sudo brew "$@"
    sudo chown "$UGRP" ${BREW}
}
