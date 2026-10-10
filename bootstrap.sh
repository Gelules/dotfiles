#!/usr/bin/env bash
# Rebuild this laptop from the repo. Idempotent: re-run it after any change.
# Usage: ./bootstrap.sh [list...]   (a list is pkglists/<name>.txt; default: base desktop dev apps aur)
#        ./bootstrap.sh base desktop    # quick VM test: no AUR, no 4 GB of TeX
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

if [[ $EUID -eq 0 ]]; then echo "Run as your user: sudo is called when needed." >&2; exit 1; fi
sudo -v   # ask the password once, fail early without sudo rights

lists=("$@"); (( $# )) || lists=(base desktop dev apps aur)
repo_files=(); aur=0
for l in "${lists[@]}"; do
    [[ -r pkglists/$l.txt ]] || { echo "No pkglists/$l.txt" >&2; exit 1; }
    if [[ $l == aur ]]; then aur=1; else repo_files+=("pkglists/$l.txt"); fi
done
pkgs() { awk '{ sub(/#.*/, ""); for (i = 1; i <= NF; i++) print $i }' "$@"; }   # names, minus comments

# 1. Dotfiles first, so that ~ is fully linked even if a later step fails or is refused.
#    home/ mirrors $HOME. Whatever is in the way is moved to a backup dir, never
#    overwritten or adopted. --no-folding: stow links files only, never a whole directory.
command -v stow >/dev/null || sudo pacman -S --needed stow
backup=$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)
while IFS= read -r -d '' f; do
    rel=${f#home/}
    [[ -e $HOME/$rel || -L $HOME/$rel ]] || continue
    [[ $(readlink -f "$HOME/$rel") == "$PWD/$f" ]] && continue   # already our link
    mkdir -p "$(dirname "$backup/$rel")"
    mv -v "$HOME/$rel" "$backup/$rel"
done < <(find home \( -type f -o -type l \) -print0)
stow --restow --no-folding --target="$HOME" home

# 2. Official packages: one transaction, full upgrade first (never a partial -Sy).
sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
if (( ${#repo_files[@]} )); then
    mapfile -t repo_pkgs < <(pkgs "${repo_files[@]}")
    sudo pacman -Syu --needed "${repo_pkgs[@]}"
fi

# 3. Root-owned files: copied, not linked (root must not depend on a file in $HOME).
while IFS= read -r -d '' f; do
    sudo install -Dm644 "$f" "/${f#system/}"
done < <(find system -type f -print0)

# 4. AUR. paru is built from source: paru-bin 2.1.0 links libalpm.so.15, pacman 7.1 ships .16.
#    home/.config/pacman/makepkg.conf (stowed in step 1) turns off the *-debug packages.
if (( aur )); then
    if ! command -v paru >/dev/null; then
        if command -v rustup >/dev/null; then rustup default stable; fi   # rustup provides cargo, ships no toolchain
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        git clone --depth 1 https://aur.archlinux.org/paru.git "$tmp/paru"
        (cd "$tmp/paru" && makepkg -si --noconfirm --rmdeps)
    fi
    mapfile -t aur_pkgs < <(pkgs pkglists/aur.txt)
    if (( ${#aur_pkgs[@]} )); then paru -S --needed --sudoloop "${aur_pkgs[@]}"; fi
fi

# 5. Services (enabled only, they start at next boot) and groups. Skips what is not installed.
for unit in NetworkManager.service bluetooth.service systemd-timesyncd.service \
            power-profiles-daemon.service fstrim.timer paccache.timer reflector.timer \
            libvirtd.socket; do
    if systemctl cat "$unit" &>/dev/null; then sudo systemctl enable "$unit"; else echo "skip $unit: not installed"; fi
done
# Keep a working display manager (GDM today). None, or a dangling link left by an uninstalled
# one (-e is false for both): LightDM. --force replaces that dangling link.
if [[ ! -e /etc/systemd/system/display-manager.service ]] && systemctl cat lightdm.service &>/dev/null; then
    sudo systemctl enable --force lightdm.service
fi
for g in libvirt wireshark nordvpn; do
    if getent group "$g" >/dev/null; then sudo usermod -aG "$g" "$(id -un)"; fi
done
if [[ -x /usr/bin/zsh && $(getent passwd "$(id -un)" | cut -d: -f7) != */zsh ]]; then chsh -s /usr/bin/zsh; fi

cat <<'EOF'

Done. Left to do by hand:
  - restore the private archive (~/.ssh, ~/.gnupg, Comic Code font): see README
  - fc-cache -f
  - git -C ~/.dotfiles remote set-url origin git@github.com:Gelules/dotfiles.git
  - vim +PlugInstall +qa
  - in the graphical session: gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  - Firefox: sign in to Firefox Sync
  - reboot: display manager, groups and login shell apply at next login
EOF
