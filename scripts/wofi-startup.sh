#!/usr/bin/env bash

STYLEDIR="$HOME/dev/config/styles/wofi"

if [[ ! $(pidof wofi) ]]; then
    if [ -z "$1" ]; then
        wofi --style "${STYLEDIR}/mocha/style.css"
    else
        wofi --style "${STYLEDIR}/$1/style.css"
    fi
else
    pkill wofi
fi
