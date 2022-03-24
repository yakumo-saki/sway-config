#!/bin/bash -u

LOG=/dev/null

set +e
swaymsg '[title=".*dropterm$"] focus' >> $LOG
xfce4-terminal --drop-down --hide-menubar --dynamic-title-mode=before --initial-title=dropterm >> $LOG

