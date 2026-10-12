#!/bin/sh
# Mirror on HDMI-1 with both screens forced to 1920x1080 (the former duplicate.sh): same
# picture on both, no cropping, but HDMI-1 only and only screens that accept 1080p.
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off
