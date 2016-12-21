#!/bin/sh

# something else is also changing these settings at startup, wait for a short moment, then put our settings
sleep 10s
gsettings set org.gnome.desktop.input-sources  sources "[('xkb', 'de'), ('xkb', 'us')]"

