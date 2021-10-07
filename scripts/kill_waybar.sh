#!/bin/bash

LOG=/tmp/kill_waybar.log
RET=`pgrep -x waybar | wc -l`

echo "`date` START Kill duplicate waybar" >> $LOG

sleep 5

if [ $RET -ge 2 ]; then
    OLD_PID=`pgrep -x waybar | head -n 1`
    echo "Kill old waybar ${OLD_PID}" >> $LOG
    kill -9 $OLD_PID
else
    echo "No duplicate waybar :)" >> $LOG
fi

echo "`date` END" >> $LOG
