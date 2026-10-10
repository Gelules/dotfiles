# TODO

## Done

- [x] Keep a list of the packages I need: `pkglists/*.txt`, installed by `bootstrap.sh`.
  The drift check in `README.md` shows what is installed but in no list.
- [x] "Flip the table" in the `fuck` function of `.zshrc` (since 2020; `toilet` is in `pkglists/apps.txt`).

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
- [ ] Media keys (play/pause, next, previous) with `playerctl`.
- [ ] Power profile menu on the battery icon (`powerprofilesctl`).
- [ ] Charge the battery only up to 80 % (UPower charge threshold, one `busctl` call).
- [ ] Screenshot keys with `scrot` + `xclip` (both installed).
- [ ] CPU temperature / RAM indicator, shown only when it gets hot or full.
