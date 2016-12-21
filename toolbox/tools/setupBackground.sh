#!/bin/sh

# something else is also changing these settings at startup, wait for a short moment, then put our settings
sleep 5s
gsettings set org.gnome.desktop.background picture-options 'stretched'

