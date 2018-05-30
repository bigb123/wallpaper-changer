#!/usr/bin/env bash
#
# Downoad latest Bing picture. set random picture to wallpaper and lock screen
#

# Cron has no $USER env var so I need to use 'whoami' command
WALLPAPER_PATH="/home/$(whoami)/Pictures/Wallpapers"

# Check if dir to store wallpapers exists
if [ ! -d "$WALLPAPER_PATH" ]; then
    mkdir -p "$WALLPAPER_PATH"
fi

cd "$WALLPAPER_PATH"

# Checkout latest picture (skip if exist <- no-clobber option)
#
# Bing api https link arguments useful info:
# idx - index number of item to display as first. Available values: 0-7.
# n - number of things to display. Available values: 0-8 (zero displays nothing).
# mkt - localization. Looks like Bing sets wallpapers depends on what language do you use.
#       Tested values that works: en-US, en-AU, pl-PL
wget --quiet --no-clobber https://www.bing.com"$(wget --quiet -O-  'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=pl-PL' | jq -r .images[0].url)"

# Get random wallpaper picture
wallpaper_uri="file://$(find $WALLPAPER_PATH -type f -name \*.jpg | sort --random-sort | head -n 1)"
echo "Next wallpaper will be: $wallpaper_uri"

# Set background
# there's a problem with setting background (it's not being set up), need to figure out why
gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"
echo "Current background: $(gsettings get org.gnome.desktop.background picture-uri)"

# Set lock screen
# there's a problem, too
gsettings set org.gnome.desktop.screensaver picture-uri "$wallpaper_uri"
echo "Current lock screen: $(gsettings get org.gnome.desktop.screensaver picture-uri)"
