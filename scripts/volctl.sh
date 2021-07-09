#!/usr/bin/env bash

me="$(basename "$0")";
running=$(ps h -C "$me" | grep -wv $$ | wc -l);
[[ $running > 1 ]] && exit;

time=4

if [[ "$1" == "mute" || "$off" == *"off"* ]]
then
    #echo `amixer set Master toggle` > /dev/null
    pamixer --toggle-mute > /dev/null
fi

if [[ "$1" == "lower" ]]
then
    #echo `amixer set Master 5%-` > /dev/null
    pamixer --decrease 5 > /dev/null
elif [[ "$1" == "raise" ]]
then
    #echo `amixer set Master 5%+` > /dev/null
    pamixer --increase 5 > /dev/null
fi

#vol=$(amixer get Master | grep -Po "[0-9]+(?=%)" | tail -1)
#off=$(amixer get Master | grep -o "off" | head -n 1)

vol=$(pamixer --get-volume)
off=$(pamixer --get-mute)

alpha="0.5"

if [[ "$1" == "mute" && "$off" == *"false"* ]]
then
    avizo-client --image-resource="volume_muted" --progress="0" --time=$time --background="rgba(255, 255, 255, $alpha)"
else
    scaled=$(echo "scale=2; $vol / 100.0" | bc)
    echo "$vol => $scaled"

    if [ "$vol" -lt "34" ]
    then
        avizo-client --image-resource="volume_low" --progress=$scaled --time=$time --background="rgba(255, 255, 255, $alpha)"
    elif [ "$vol" -lt "67" ]
    then
        avizo-client --image-resource="volume_medium" --progress=$scaled --time=$time --background="rgba(255, 255, 255, $alpha)"
    elif [ "$vol" -lt "101" ]
    then
        avizo-client --image-resource="volume_high" --progress=$scaled --time=$time --background="rgba(255, 255, 255, $alpha)"
    fi
fi

