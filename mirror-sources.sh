#!/bin/bash
# mirrors every upstream git source into a github.com/unity-arch/<name> repo so ci doesn't
# depend on gitlab being up.
# rerun it to sync. usage: ./mirror-sources.sh [name...]
set -e
here=$(cd "$(dirname "$0")" && pwd)
work=${MIRROR_WORK:-$here/mirrors}
mkdir -p "$work"

# name=upstream url, launchpad ones are the ubuntu/devel packaging branches
sources=(
  nux=https://gitlab.com/ubuntu-unity/unity/nux.git
  unity=https://gitlab.com/ubuntu-unity/unity/unity.git
  unity-control-center=https://gitlab.com/ubuntu-unity/unity/unity-control-center.git
  unity-greeter=https://gitlab.com/ubuntu-unity/unity/unity-greeter.git
  unity-lens-applications=https://gitlab.com/ubuntu-unity/unity/unity-lens-applications.git
  unity-lens-files=https://gitlab.com/ubuntu-unity/unity/unity-lens-files.git
  unity-scope-home=https://gitlab.com/ubuntu-unity/unity/unity-scope-home.git
  unity-session=https://gitlab.com/ubuntu-unity/unity/unity-session.git
  unity-settings-daemon=https://gitlab.com/ubuntu-unity/unity/unity-settings-daemon.git
)

want=("$@")
failed=()
for entry in "${sources[@]}"; do
  name=${entry%%=*}
  url=${entry#*=}
  if [[ ${#want[@]} -gt 0 ]] && [[ ! " ${want[*]} " == *" $name "* ]]; then continue; fi
  dir="$work/$name.git"
  echo "==> $name"
  for attempt in 1 2 3 4 5 6; do
    if [[ -d "$dir" ]]; then
      git -C "$dir" remote update --prune && break
    else
      git clone --mirror "$url" "$dir" && break
    fi
    [[ $attempt -eq 6 ]] && { echo "giving up on $name"; exit 1; }
    sleep $((attempt * 30))
  done
  gh repo view "unity-arch/$name" >/dev/null 2>&1 ||
    gh repo create "unity-arch/$name" --public --description "mirror of $url, used by unity-arch/packages" >/dev/null
  # github's rule validation times out now and then on big tag pushes, a retry gets through
  pushed=0
  for attempt in 1 2 3; do
    git -C "$dir" push --mirror "https://github.com/unity-arch/$name.git" && { pushed=1; break; }
    sleep 15
  done
  (( pushed )) || failed+=("$name")
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "failed: ${failed[*]}"
  exit 1
fi
