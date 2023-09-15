#!/bin/sh
set -e

WINEVERSION=$WINEVERSION
WINEHOME="/home/root"
WINEPREFIX="$WINEHOME/.wine32"
WINEARCH="win32"
WINEDEBUG=-all

ensure_nanolayer nanolayer_location "v0.5.0"

$nanolayer_location \
  install \ 
  apt-get \ 
    apt-transport-https \
    ca-certificates \
    telnet \
    cabextract \
    gnupg2 \
    wget

wget https://dl.winehq.org/wine-builds/winehq.key -O - | apt-key add -
echo "deb https://dl.winehq.org/wine-builds/debian bookworm main" > /etc/apt/sources.list.d/winehq.list
{ \
	echo "Package: *wine* *wine*:i386"; \
	echo "Pin: version $WINEVERSION~bookworm"; \
	echo "Pin-Priority: 1001"; \
} > /etc/apt/preferences.d/winehq.pref

$nanolayer_location install apt-get winehq-stable
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
chmod +rx /usr/bin/winetricks