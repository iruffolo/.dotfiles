#!/usr/bin/env bash

if [[ ! $(pidof pavucontrol) ]]; then
    pavucontrol
else
    pkill pavucontrol 
fi
