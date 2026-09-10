#!/bin/bash
# builds packages with the repo makepkg config into repo/, in dependency order.
# usage: ./build.sh [-i] [pkg...]   (-i installs each package after it builds, needed
# for a full chain build since later packages link against earlier ones)
set -e
here=$(cd "$(dirname "$0")" && pwd)

order=(
  glewmx frame grail geis xpathselect cmake-extras
  ido libindicator-gtk3 libunity-misc gsettings-ubuntu-schemas unity-asset-pool
  dee libunity nux compiz-ubuntu
  unity-settings-daemon unity-session
  indicator-session indicator-power indicator-bluetooth indicator-printers indicator-application
  indicator-messages indicator-datetime indicator-sound indicator-keyboard
  unity-gtk-module libcolumbus hud indicator-appmenu
  unity unity-greeter ubuntu-unity-settings
  unity-scope-home unity-lens-files unity-lens-applications
  libtimezonemap libgeonames unity-control-center
  unity-desktop
)

install=0
if [[ $1 == -i ]]; then install=1; shift; fi
pkgs=("$@")
[[ ${#pkgs[@]} -eq 0 ]] && pkgs=("${order[@]}")

for p in "${pkgs[@]}"; do
  [[ -f "$here/pkgs/$p/PKGBUILD" ]] || { echo "skipping $p, no pkgbuild yet"; continue; }
  echo "==> building $p"
  # launchpad's git server drops connections often enough to break ci, fetch first with retries
  for attempt in 1 2 3 4 5; do
    (cd "$here/pkgs/$p" && makepkg --config "$here/makepkg.conf" -od --noconfirm) && break
    [[ $attempt -eq 5 ]] && exit 1
    sleep $((attempt * 20))
  done
  (cd "$here/pkgs/$p" && makepkg --config "$here/makepkg.conf" -sfe --noconfirm)
  if (( install )); then
    # newest file for this package name, epoch and pkgrel included
    pkgfile=$(ls -t "$here"/repo/"$p"-[0-9]*.pkg.tar.zst | head -1)
    sudo pacman -U --noconfirm "$pkgfile"
  fi
done
