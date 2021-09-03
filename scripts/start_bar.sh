#!/bin/bash

# このファイル名を waybar が含まれるものにすると pgrep が検出してしまう

pgrep waybar
RET=$?
echo `date` RET = ${RET} >> ~/start_bar.log
if [ $RET -ne 0 ]; then
    waybar
fi
