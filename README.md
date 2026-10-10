# dotfiles

I got a lot of inspiration from Kevin Sztern's dotfiles: https://github.com/Chewie/dotfiles

## Layout

- `home/`: the only stow package, an exact mirror of `$HOME`
  (`stow --restow --no-folding -t ~ home`).
- `pkglists/`: package lists, one name per line, `#` comments: `base`, `desktop`, `dev`, `apps`, `aur`,
  and an optional `gnome` fallback.
- `system/`: root-owned files (e.g. the touchpad config), copied by `bootstrap.sh`, never linked.
- `bootstrap.sh`: links `home/` first (a failed or refused upgrade never leaves `~` unlinked), then installs the
  lists, copies `system/` and enables the services. Idempotent: re-run it after any change.
- `archinstall.json`: optional answers for the base install (no disk layout, no passwords).

Keep the repository where it is cloned: the files in `~` are symlinks into it.

## (Re)install

1. From the Arch ISO, either
   `archinstall --config-url https://raw.githubusercontent.com/Gelules/dotfiles/master/archinstall.json`
   (you still pick the disk, the user and the passwords; it clones this repo into `~/.dotfiles`), or install by hand
   and `git clone https://github.com/Gelules/dotfiles ~/.dotfiles`.
2. First login: `~/.dotfiles/bootstrap.sh` (`./bootstrap.sh base desktop` for a smaller first run, e.g. in a VM),
   then the manual steps it prints. Reboot.

Files already in the way are moved to `~/.dotfiles-backup/<date>/`, never overwritten.

## Manual steps

- Restore the private archive (SSH/GPG keys, the commercial Comic Code font):
  `gpg -d secrets.tgz.gpg | tar -C ~ -xzf - && fc-cache -f`. It is made with
  `tar -C ~ -czf - .ssh .gnupg .local/share/fonts | gpg -c -o ~/secrets.tgz.gpg`. Never commit keys or the font.
- `vim +PlugInstall +qa`, then `rustup default stable && rustup component add rust-analyzer` (Vim LSP).
- From the graphical session: `gsettings set org.gnome.desktop.interface color-scheme prefer-dark` and
  `xdg-settings set default-web-browser firefox.desktop`.
- Firefox Sync, and the logins (NordVPN, Discord...).
- Once the SSH keys are back: `git -C ~/.dotfiles remote set-url origin git@github.com:Gelules/dotfiles.git`.

## Keeping the package lists honest

Packages installed explicitly but in no list:

```sh
comm -23 <(pacman -Qqe | sort) <(awk '{sub(/#.*/,""); for(i=1;i<=NF;i++) print $i}' ~/.dotfiles/pkglists/*.txt | sort -u)
```

## Test in a throwaway VM

```sh
mkdir -p ~/vm && cp /usr/share/edk2/x64/OVMF.4m.fd ~/vm/ovmf.fd && qemu-img create -f qcow2 ~/vm/arch.qcow2 40G
qemu-system-x86_64 -enable-kvm -cpu host -smp 4 -m 4G -vga virtio -nic user,model=virtio-net-pci \
  -drive if=pflash,format=raw,file="$HOME/vm/ovmf.fd" -drive file="$HOME/vm/arch.qcow2",if=virtio -cdrom archlinux-x86_64.iso
```

Install with archinstall (disk `/dev/vda`), take a snapshot (`qemu-img snapshot -c fresh ~/vm/arch.qcow2`), then run
`~/.dotfiles/bootstrap.sh base desktop` twice: the second run must change nothing. To test a branch, run
`git -C ~/.dotfiles switch <branch>` first (archinstall clones the default branch).
