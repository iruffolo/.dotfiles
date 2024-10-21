#!/usr/bin/env bash

if [[ ! $(pidof keymapp) ]]; then
    ~/.local/bin/keymapp
else
    pkill keymapp 
fi
