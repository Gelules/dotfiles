#!/bin/sh
# Mirror the laptop screen on every plugged screen (HDMI or DP), each in its own preferred
# mode (--auto). Nothing is scaled: if the sizes differ, the larger screen shows the smaller
# one's picture plus a strip of desktop beyond it. Same picture everywhere: fullhd.sh (forces
# 1920x1080 on both) or autorandr's clone-largest (scales down, F7 menu).
set -- --output eDP-1 --auto --primary
for out in $(xrandr --query | awk '$1 != "eDP-1" && $2 == "connected" { print $1 }'); do
    set -- "$@" --output "$out" --auto --same-as eDP-1
done
for out in $(xrandr --query | awk '$2 == "disconnected" { print $1 }'); do
    set -- "$@" --output "$out" --off
done
exec xrandr "$@"
