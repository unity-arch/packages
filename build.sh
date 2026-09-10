#!/bin/bash
# builds the given packages (or the whole ordered list) with the repo makepkg config,
# results land in repo/. installing is left to you, pass -i to makepkg via ARGS
set -e
here=$(cd "$(dirname "$0")" && pwd)
order=(glewmx frame grail xpathselect ido libindicator-gtk3 libunity-misc gsettings-ubuntu-schemas unity-asset-pool geis)
pkgs=("$@")
[[ ${#pkgs[@]} -eq 0 ]] && pkgs=("${order[@]}")
for p in "${pkgs[@]}"; do
  echo "==> building $p"
  (cd "$here/pkgs/$p" && makepkg --config "$here/makepkg.conf" -sf ${ARGS:-})
done
