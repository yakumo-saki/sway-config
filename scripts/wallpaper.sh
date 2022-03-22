#!/bin/bash -eu
# @(#) This script changes wallpaper 

WALLPAPER_DIR=~/Dropbox/99_private/wallpaper
#DISPLAY_0=HDMI-A-3
#DISPLAY_1=DVI-D-1
DISPLAY_0=$1
DISPLAY_1=$2
PIDFILE=/tmp/wallpaper.sh.pid

function change_wallpaper() {
    NEXT_WP0=`find ${WALLPAPER_DIR}/. -type f | shuf -n 1`
    NEXT_WP1=`find ${WALLPAPER_DIR}/. -type f | shuf -n 1`
    echo "$(date) NEXT WALLPAPER0=${NEXT_WP0}"
    echo "$(date) NEXT WALLPAPER1=${NEXT_WP1}"
    #swaybg -i ${NEXT_WP} -m fill &
    swaymsg output ${DISPLAY_0} bg ${NEXT_WP0} fill "#000000"
    swaymsg output ${DISPLAY_1} bg ${NEXT_WP1} fill "#000000"
}	

function kill_last_process() {
    if [ -e $PIDFILE ]; then
        LASTPID=`cat $PIDFILE`
	echo "[`LANG=C date`] Kill last process $LASTPID"
	set +e
        kill $LASTPID
	set -e
    fi
}

kill_last_process
echo $$
echo $$ > $PIDFILE

change_wallpaper
while true; do
    echo "[`LANG=C date`] Wait for next wallpaper change"
    sleep 1190
    change_wallpaper
done


