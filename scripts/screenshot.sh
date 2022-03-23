#!/bin/bash
set -eu

## FROM https://raw.githubusercontent.com/yschaeff/sway_screenshots/master/screenshot.sh

## USER PREFERENCES ##
#MENU="dmenu -i"
MENU="rofi -i -dmenu"
RECORDER=wf-recorder
TARGET=$(xdg-user-dir PICTURES)/screenshots
TARGET_VIDEOS=$(xdg-user-dir PICTURES)/screencasts
#NOTIFY=$(pidof mako || pidof dunst) || true
NOTIFY=true
FOCUSED=$(swaymsg -t get_tree | jq '.. | ((.nodes? + .floating_nodes?) // empty) | .[] | select(.focused and .pid) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
WINDOWS=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
REC_PID=$(pidof $RECORDER) || true

# recoding filename temp file.
REC_TMP_FILE="/tmp/__screenrecording_filename__.txt"

FILENAME="$TARGET/$(date +'%Y%m%d_%H%M%S_screenshot.png')"
RECORDING_FILENAME="$(date +'%Y%m%d_%H%M%S_recording.mp4')"
RECORDING="${TARGET_VIDEOS}/${RECORDING_FILENAME}"

# make sure directory exists
mkdir -p $TARGET
mkdir -p $TARGET_VIDEOS

# 12x6+0.5+0 GIMP
# -unsharp 10x5+0.7+0 よき
# -unsharp 2x1.4+0.5+0 ぼやける
#CONVERT_OPTS="-unsharp 12x6+0.5+0 -quality 100"
# https://qiita.com/yoya/items/b1590de289b623f18639
CONVERT_OPTS="-colorspace RGB -filter Lanczos -define filter:blur=.9891028367558475 -colorspace sRGB"

notify() {
    ## if the daemon is not running notify-send will hang indefinitely
    if [ $NOTIFY ]; then
        notify-send "$@"
    else
        echo NOTICE: notification daemon not active
        echo "$@"
    fi
}

notify-rec() {
    notify "Screen Recording" "Target: $1"
    rm -f $REC_TMP_FILE
    echo "$RECORDING_FILENAME" > $REC_TMP_FILE
}

if [ ! -z $REC_PID ]; then
    echo "pid: $REC_PID"
    kill -SIGINT $REC_PID
    
    if [ -e $REC_TMP_FILE ]; then
        REC_FILENAME=`cat $REC_TMP_FILE`
        notify "End Recoding" "Recorded: \n$REC_FILENAME" -t 2000
    else
        notify "End Recoding" "Recorded" -t 2000
    fi

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

case "$CHOICE" in
    "Fullscreen")
        grim "$FILENAME" ;;
    "Region")
        slurp | grim -g - "$FILENAME" ;;
    "Region-Resize-Half")
        slurp | grim -g - "$FILENAME"
        ORG_FILENAME=$FILENAME
        FILENAME=${TARGET}/`basename ${FILENAME} .png`-half.png
        convert $ORG_FILENAME $CONVERT_OPTS -distort Resize 50% $FILENAME
        rm $ORG_FILENAME
        ;;
    "Region-Resize-25percent")
        slurp | grim -g - "$FILENAME"
        ORG_FILENAME=$FILENAME
        FILENAME=${TARGET}/`basename ${FILENAME} .png`-25.png
	    convert $ORG_FILENAME $CONVERT_OPTS -distort Resize 25% $FILENAME
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
        $RECORDER -g "$(echo "$OUTPUTS"|slurp)" -f "$RECORDING" &
        notify-rec "Display"

        REC=1 ;;
    "Record-select-window")
        PARAM="$(echo "$WINDOWS"|slurp)"
        $RECORDER -g "$(echo "$WINDOWS"|slurp)" -f "$RECORDING" &
        notify-rec "Window"
      
        REC=1 ;;
    "Record-region")
        PARAM="$(slurp)"
        $RECORDER -g "${PARAM}" -f "$RECORDING" &
        notify-rec "Region"

        REC=1 ;;
    "Record-focused")
        $RECORDER -g "$(eval echo $FOCUSED)" -f "$RECORDING" &
        notify-rec "Focused"

        REC=1 ;;
    *)
        grim -g "$(eval echo $CHOICE)" "$FILENAME" ;;
esac


if [ $REC ]; then
    echo "rec start"
else
    notify "Screenshot saved" "File saved as \n$FILENAME\nand copied to clipboard" -t 6000 -i $FILENAME
    wl-copy < $FILENAME
    # feh $FILENAME
fi

