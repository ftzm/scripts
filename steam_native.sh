#!/bin/sh
export STEAM_RUNTIME=0
# Workaround for dbus fatal termination related coredumps (SIGABRT)
# https://github.com/ValveSoftware/steam-for-linux/issues/4464
export DBUS_FATAL_WARNINGS=0
# Override some libraries as these are what games linked against.
export LD_LIBRARY_PATH="/usr/lib/steam:/usr/lib32/steam"
#export LD_PRELOAD='/usr/lib32/libudev.so.1 /usr/lib32/libcrypto-compat.so.1.0.0 /usr/lib32/libssl-compat.so.1.0.0 usr/lib/libudev.so.1 /usr/lib/libcrypto-compat.so.1.0.0 /usr/lib/libssl-compat.so.1.0.0'
exec /usr/lib/steam/steam "$@"
