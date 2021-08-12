#!/bin/bash

swaymsg "output * dpms on"

if pgrep waybar ; then
    echo "swayidle resume. waybar process ok"
else 
    waybar
fi
