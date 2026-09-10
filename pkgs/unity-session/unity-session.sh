#!/bin/sh
# session entry point, the systemd user units need the x11 environment the display
# manager gave us, and a stale wayland display from a previous session would make
# unity-settings-daemon pick the wayland gdk backend and crash
systemctl --user unset-environment WAYLAND_DISPLAY
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP DESKTOP_SESSION XDG_SEAT XDG_VTNR
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP DESKTOP_SESSION

exec /usr/lib/unity-session/run-systemd-session unity-session.target "$@"
