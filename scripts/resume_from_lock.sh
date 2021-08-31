#!/bin/bash

swaymsg "output * dpms on"

sleep 3
# kill -9 : SIGKILL
#pgrep waybar | xargs -I{} kill -9 {}
pkill -9 waybar
sleep 1
waybar
