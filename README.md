# unity-arch

pkgbuilds for running the unity 7 desktop on arch linux.

sources come from the ubuntu unity project (https://gitlab.com/ubuntu-unity/unity) and the ubuntu archive on launchpad, patched only where arch differs from ubuntu (no replacement gtk3, no python2).

## layout

- `pkgs/<name>/PKGBUILD`, one directory per package, patches live next to the pkgbuild
- `build.sh`, builds every package in dependency order (or the ones you name) into `repo/`
- `makepkg.conf`, plain arch build flags, sourced on top of the system one

## building

```
./build.sh            # everything, in order
./build.sh nux unity  # just these
```

packages land in `repo/`, install them with `pacman -U`.

## using the binary repo

packages built by ci are published on the `repo` release. add to `/etc/pacman.conf`:

```
[unity-arch]
SigLevel = Optional TrustAll
Server = https://github.com/unity-arch/packages/releases/download/repo
```

then `pacman -Sy unity unity-session unity-greeter`.
