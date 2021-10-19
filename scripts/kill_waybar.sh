#!/bin/bash

LOG=/tmp/kill_waybar.log

function kill_old_waybar () {
    RET=`pgrep -x waybar | wc -l`
    if [ $RET -ge 2 ]; then
        OLD_PID=`pgrep -x waybar | head -n 1`
        echo "[attempt $1] Kill old waybar ${OLD_PID}" >> $LOG
        kill -9 $OLD_PID
    else
        echo "[attempt $1] No duplicate waybar :)" >> $LOG
    fi
}

echo "`date` START Kill duplicate waybar" >> $LOG

sleep 5
kill_old_waybar 1

sleep 5
kill_old_waybar 2

sleep 5
kill_old_waybar 3

echo "`date` END" >> $LOG
