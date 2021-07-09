#!/bin/bash 
pamixer --toggle-mute
MUTED=`pamixer --get-mute`

if [ "${MUTED}" = "true" ]; then
  echo "0"
else
  VOLUME=`pamixer --get-volume`
  echo "$VOLUME"
fi
