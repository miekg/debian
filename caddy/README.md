# Debian

This holds a few files to create a Debian package for Caddy - it's tailored for my own use, i.e.
using `miek@miek.nl` in a few places. But feel free to send PR to make it more generic.

Builds a package from a *pre-compiled* binary, uses the user `www-data` and a systemd unit file. The
configuration is put in `/etc/caddy`.

## Building

Building the caddy binary is left out, we expect a precompiled binary in the local directory.
