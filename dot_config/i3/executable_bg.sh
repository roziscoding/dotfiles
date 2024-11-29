#!/bin/sh

# systemd example: https://stackoverflow.com/a/50321912
# cron example:
# 0 * * * * ~/.config/sway/scripts/bing_wallpaper.sh

# exit on error
set -e

# set $SWAYSOCK if it's not set (for systemd or cron)
if [ -z "$SWAYSOCK" ]; then
  export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock
fi

currentdate=$(date --iso)
wlpath=${WALLPAPER_PATH:-"$HOME/Pictures/Wallpapers/$currentdate"}
output=${WALLPAPER_OUTPUT:-"*"}
baseurl="https://bing.biturl.top?format=image&resolution=UHD&mkt=en-US"

echo $wlpath

mkdir -p $wlpath

echo $wlpath/regular.jpg
https $baseurl -d --output $wlpath/regular.jpg

killall swaybg || true

swaymsg "output $output bg $wlpath/regular.jpg fill"

convert $wlpath/regular.jpg -filter Gaussian -blur 0x8 -level 10%,90%,0.5 $wlpath/lock.jpg

ln -sfn $wlpath/regular.png $HOME/Pictures/Wallpapers/regular.png
ln -sfn $wlpath/lock.png $HOME/Pictures/Wallpapers/lock.png

