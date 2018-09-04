#!/usr/bin/env bash
#
# Downoad latest Bing picture. set random picture as wallpaper and lock screen
# This script is designed to run with Cron (but can be executed manually, too)
#

# CONSTS
#
# Cron has no $USER env var so I need to use 'whoami' command
WALLPAPER_PATH="/home/$(whoami)/Pictures/Wallpapers"
# Add snap binaries to PATH (jq can be installed there) as normally cron has only PATH=/usr/bin
PATH="$PATH:/snap/bin"

# Need to export current dbus session bus address. Other way gsettings won't
# work. It is responsible for setting up wallpaper and lock screen picture.
export "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus"
# $(grep -z "DBUS_SESSION_BUS_ADDRESS" /proc/"$(pgrep -n gnome-session)"/environ)
# In case above won't work:
# export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Check if dir to store wallpapers exists
if [ ! -d "$WALLPAPER_PATH" ]; then
    mkdir -p "$WALLPAPER_PATH" || echo "Cannot create path to store wallpapers"

    # Download some latest wallpapers from Bing to provide some randomize.
    cd "$WALLPAPER_PATH" || exit 1
    # Bing link parameters explanation is available below.
    for imagelink in $(wget --quiet -O-  'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=en-AU' | jq -r .images[].url); do
      wget --quiet --no-clobber "https://www.bing.com$imagelink"
    done
fi

cd "$WALLPAPER_PATH" || exit 1
# Move oldest pictures to Archive and keep just a bunch of them as active.
number_of_wallpapers_to_keep=30
number_of_current_wallpaper=0
mkdir -p "Archive"
for wallpaper in $(ls -t *.jpg); do
  if [ $number_of_current_wallpaper -lt $number_of_wallpapers_to_keep ]; then
    # Keep the wallpaper
    number_of_current_wallpaper=$(($number_of_current_wallpaper+1))
  else
    # Remove wallpaper
    mv "$wallpaper" Archive/
  fi
done

# Checkout latest picture (skip if exist -> no-clobber option)
#
# Bing api https link arguments useful info:
# idx - index number of item to display as first. Available values: 0-7.
# n - number of things to display. Available values: 0-8 (zero displays nothing).
# mkt - localization (market). Looks like Bing sets wallpapers depends on what
#       language do you use. Tested values that works: en-US, en-AU, pl-PL.
wget --quiet --no-clobber "https://www.bing.com$(wget --quiet -O- 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-AU' | jq -r .images[0].url)"

# Get random wallpaper picture
wallpaper_uri="file://$(find $WALLPAPER_PATH -maxdepth 1 -type f -name \*.jpg | sort --random-sort | head -n 1)"

# Set background
gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"

# Set lock screen
gsettings set org.gnome.desktop.screensaver picture-uri "$wallpaper_uri"
