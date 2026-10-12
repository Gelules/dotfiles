# TODO

## Done

- [x] Keep a list of the packages I need: `pkglists/*.txt`, installed by `bootstrap.sh`.
  The drift check in `README.md` shows what is installed but in no list.
- [x] "Flip the table" in the `fuck` function of `.zshrc` (since 2020; `toilet` is in `pkglists/apps.txt`).
- [x] Screen layouts on F7: autorandr profiles (saved from the menu, reapplied on hotplug and at login),
  `~/.screenlayout/*.sh`, autorandr's built-in layouts, arandr. `duplicate.sh` mirrors any plugged screen
  (`--auto --same-as eDP-1`); the old 1080p HDMI mirror is `fullhd.sh`.
- [x] Wibar: now playing + media keys (`playerctl`), power profile, night light (`gammastep`), and icons
  shown only when something is wrong: failed systemd units, CPU / RAM / temperature, `/` over 90 %.
- [x] Keys: Print / Shift+Print (screenshot to `~/Pictures/Screenshots` + clipboard), Mod4+² drop-down terminal.
- [x] Faster key repeat (250 ms, 40/s), Caps Lock = Escape, battery charged up to 80 % only.
- [x] Vim: system clipboard (OSC 52), true colours, cursor shape by mode. zsh: exit code in the prompt.
- [x] git-delta as git pager; pacman `VerbosePkgLists`; Arch news in `paru -Syu` (`NewsOnUpgrade`).

## To do

- [ ] Change the wallpaper easily. Idea: a "wallpaper" submenu in awesome's main menu (Mod4+w) listing
  `~/.config/awesome/wallpaper-*.png`, applied with `gears.wallpaper.fit` and remembered in `~/.cache/awesome/`.
  `wallpaper-white.png` is kept for this, but the Stencil theme is designed for the black one.
- [ ] Keep `pkglists/` up to date: run the drift check after installing something new.
- [ ] Run `bootstrap.sh` on a fresh system (throwaway VM, see `README.md`): it has never run from scratch.
- [ ] Try `archinstall.json` at the next install: never run for real, and archinstall's format changes between
  versions.
- [ ] Review `pkglists/aur.txt`: are `python2` (end of life), `hfsprogs` and `piper-tts-git` (built from upstream
  HEAD) still needed? Fewer AUR packages, less supply-chain risk.

## Ideas, not decided

- [ ] rofi as launcher (window switcher, dmenu-style menus).
