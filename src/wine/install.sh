#!/bin/sh
set -e

WINEVERSION="${VERSION:-"latest"}"

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

  if [ "${WINEVERSION}" != "latest" ]; then
    {
      echo "Package: *wine* *wine*:i386"
      echo "Pin: version $WINEVERSION~$VERSION_CODENAME"
      echo "Pin-Priority: 1001"
    } >/etc/apt/preferences.d/winehq.pref
  fi

  apt-get update
  apt-get install -y --no-install-recommends winehq-staging

  wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
  chmod +rx /usr/bin/winetricks

  su -l $_REMOTE_USER -c "WINEPREFIX=\"$_REMOTE_USER_HOME\" wine wineboot --init"

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
