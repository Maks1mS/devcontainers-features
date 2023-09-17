#!/bin/sh
set -e

WINEVERSION=$WINEVERSION
WINEHOME="/home/root"
WINEPREFIX="$WINEHOME/.wine32"
WINEARCH="win32"
WINEDEBUG=-all

install_debian() {
  export DEBIAN_FRONTEND=noninteractive
  dpkg --add-architecture i386
  apt-get update
  apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    telnet \
    cabextract \
    gnupg2 \
    wget

  wget https://dl.winehq.org/wine-builds/winehq.key -O - | apt-key add -
  echo "deb https://dl.winehq.org/wine-builds/debian $VERSION_CODENAME main" >/etc/apt/sources.list.d/winehq.list
  {
    echo "Package: *wine* *wine*:i386"
    echo "Pin: version $WINEVERSION~$VERSION_CODENAME"
    echo "Pin-Priority: 1001"
  } >/etc/apt/preferences.d/winehq.pref

  apt-get update
  apt-get install -y --no-install-recommends winehq-stable
  wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
  chmod +rx /usr/bin/winetricks

  apt purge --auto-remove -y
  apt autoremove --purge -y
  rm -rf /var/lib/apt/lists/*
}

. /etc/os-release

if [ "${ID}" = "debian" ]; then
  install_debian
else
  echo "Linux distro ${ID} not supported."
  exit 1
fi
