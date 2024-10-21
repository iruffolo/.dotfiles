#!/usr/bin/env bash

# Search for pid with pgrep - waypaper is called as a python script
if [[ ! $(pgrep -f /usr/bin/waypaper) ]]; then
    waypaper
else
    pkill waypaper
fi
