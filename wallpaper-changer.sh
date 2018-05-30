#!/usr/bin/env bash
#
# Downoad latest Bing picture. set random picture to wallpaper and lock screen
# This script is designed to run with Cron (but can be executed manually, too)
#

# CONSTS
#
# Cron has no $USER env var so I need to use 'whoami' command
WALLPAPER_PATH="/home/$(whoami)/Pictures/Wallpapers"
# Add snap binaries to PATH (jq can be installed there) as normally cron has only PATH=/usr/bin
PATH="$PATH:/snap/bin"

# Need to export current dbus session bus address. Other way gsettings won't work
export $(grep -z "DBUS_SESSION_BUS_ADDRESS" /proc/$(pgrep -n gnome-session)/environ)

# Check if dir to store wallpapers exists
if [ ! -d "$WALLPAPER_PATH" ]; then
    mkdir -p "$WALLPAPER_PATH"
    # TODO: Download some latest wallpapers from Bing
fi

cd "$WALLPAPER_PATH"

# Checkout latest picture (skip if exist <- no-clobber option)
#
# Bing api https link arguments useful info:
# idx - index number of item to display as first. Available values: 0-7.
# n - number of things to display. Available values: 0-8 (zero displays nothing).
# mkt - localization. Looks like Bing sets wallpapers depends on what language do you use.
#       Tested values that works: en-US, en-AU, pl-PL
wget --quiet --no-clobber "https://www.bing.com$(wget --quiet -O-  'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-AU' | jq -r .images[0].url)"

# Leaving commented echoes as I'm still testing it if DBUS_SESSION_BUS_ADDRESS env works

# Get random wallpaper picture
wallpaper_uri="file://$(find $WALLPAPER_PATH -type f -name \*.jpg | sort --random-sort | head -n 1)"
#echo "Next wallpaper will be: $wallpaper_uri"

# Set background
gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"
#echo "Current background: $(gsettings get org.gnome.desktop.background picture-uri)"

# Set lock screen
gsettings set org.gnome.desktop.screensaver picture-uri "$wallpaper_uri"
#echo "Current lock screen: $(gsettings get org.gnome.desktop.screensaver picture-uri)"
