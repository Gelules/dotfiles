#!/usr/bin/env bash

function run {
  if ! pgrep $1; then
    $@&
  fi
}

run dbus-launch update-checker
run pulseaudio -D
run xfce4-power-manager
