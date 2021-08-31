#!/bin/bash
set -e

## FROM https://raw.githubusercontent.com/yschaeff/sway_screenshots/master/screenshot.sh

## USER PREFERENCES ##
#MENU="dmenu -i"
MENU="rofi -i -dmenu"
RECORDER=wf-recorder
TARGET=$(xdg-user-dir PICTURES)/screenshots
TARGET_VIDEOS=$(xdg-user-dir PICTURES)/screencasts
NOTIFY=$(pidof mako || pidof dunst) || true
FOCUSED=$(swaymsg -t get_tree | jq '.. | ((.nodes? + .floating_nodes?) // empty) | .[] | select(.focused and .pid) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
WINDOWS=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
REC_PID=$(pidof $RECORDER) || true

notify() {
    ## if the daemon is not running notify-send will hang indefinitely
    if [ $NOTIFY ]; then
        notify-send "$@"
    else
        echo NOTICE: notification daemon not active
        echo "$@"
    fi
}

if [ ! -z $REC_PID ]; then
    echo pid: $REC_PID
    kill -SIGINT $REC_PID
    notify "Screen recorder stopped" -t 2000
    exit 0
fi

# Added
echo $#
if [ $# == 0 ]; then
echo "Show menu"
# -l is number of lines
# -a is active (blue text) -u is urgent (red background)
CHOICE=`$MENU -l 15 -a 0,1,2,3,4,5,6,7 -u 9,10,11,12,13 -p "How to make a screenshot?" -select "Region-Resize-Half" << EOF
Fullscreen
Focused
Select-window
Select-output
Region
Region-Resize-Half
Region-Resize-25percent

Color-Picker

Record-focused
Record-select-window
Record-select-output
Record-region
EOF`
else
  echo "From param $1"
  CHOICE=$1
fi

mkdir -p $TARGET
mkdir -p $TARGET_VIDEOS
FILENAME="$TARGET/$(date +'%Y%m%d_%H%M%S_screenshot.png')"
RECORDING="$TARGET_VIDEOS/$(date +'%Y-%m-%d_%Hh%Mm%Ss_recording.mp4')"

case "$CHOICE" in
    "Fullscreen")
        grim "$FILENAME" ;;
    "Region")
        slurp | grim -g - "$FILENAME" ;;
    "Region-Resize-Half")
        slurp | grim -g - "$FILENAME"
        ORG_FILENAME=$FILENAME
        FILENAME=${TARGET}/`basename ${FILENAME} .png`-half.png
        convert $ORG_FILENAME -resize 50% $FILENAME
        rm $ORG_FILENAME
        ;;
    "Region-Resize-25percent")
        slurp | grim -g - "$FILENAME"
        ORG_FILENAME=$FILENAME
        FILENAME=${TARGET}/`basename ${FILENAME} .png`-25.png
	convert $ORG_FILENAME -resize 25% $FILENAME
        ;;
    "Select-output")
        echo "$OUTPUTS" | slurp | grim -g - "$FILENAME" ;;
    "Select-window")
        echo "$WINDOWS" | slurp | grim -g - "$FILENAME" ;;
    "Focused")
        grim -g "$(eval echo $FOCUSED)" "$FILENAME" ;;
    "Color-Picker")
        COLOR=`grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n 1 | cut -d ' ' -f 4`
        echo "$COLOR picked"
        echo $COLOR | wl-copy
        notify "Color Picker" "Color picked is\n${COLOR} Copied to clipboard" -t 6000
        exit;;
    "Record-select-output")
        $RECORDER -g "$(echo "$OUTPUTS"|slurp)" -f "$RECORDING"
        REC=1 ;;
    "Record-select-window")
        $RECORDER -g "$(echo "$WINDOWS"|slurp)" -f "$RECORDING"
      
        REC=1 ;;
    "Record-region")
        $RECORDER -g "$(slurp)" -f "$RECORDING"
        REC=1 ;;
    "Record-focused")
        $RECORDER -g "$(eval echo $FOCUSED)" -f "$RECORDING"
        REC=1 ;;
    *)
        grim -g "$(eval echo $CHOICE)" "$FILENAME" ;;
esac


if [ $REC ]; then
    notify "Recording" "Recording stopped: $RECORDING" -t 10000
    wl-copy < $RECORDING
else
    notify "Screenshot" "File saved as \n$FILENAME\nand copied to clipboard" -t 6000 -i $FILENAME
    wl-copy < $FILENAME
    # feh $FILENAME
fi

