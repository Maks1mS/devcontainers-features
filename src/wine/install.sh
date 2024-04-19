#!/bin/bash
set -e

WINEVERSION="${VERSION:-"latest"}"

WINEHOME=$_REMOTE_USER_HOME
WINEPREFIX="$WINEHOME/.wine32"
# WINEARCH="win32"
# WINEDEBUG="-all"

COREFONTS_BASE_URL="https://raw.githubusercontent.com/Maks1mS/devcontainers-features/main/src/wine/corefonts/"
COREFONTS_FILES=(
  "andale32.exe"
  "arial32.exe"
  "arialb32.exe"
  "courie32.exe"
  "georgi32.exe"
  "impact32.exe"
  "times32.exe"
  "trebuc32.exe"
  "verdan32.exe"
  "wd97vwr32.exe"
  "webdin32.exe"
  "comic32.exe"
)
COREFONTS_CACHE_DIR="\$HOME/.cache/winetricks/corefonts/"

update_rc_file() {
  # see if folder containing file exists
  local rc_file_folder
  rc_file_folder="$(dirname "$1")"
  if [ ! -d "${rc_file_folder}" ]; then
    echo "${rc_file_folder} does not exist. Skipping update of $1."
  elif [ ! -e "$1" ] || [[ "$(cat "$1")" != *"$2"* ]]; then
    echo "$2" >>"$1"
  fi
}

add_wine_repo() {
  wget -nv https://dl.winehq.org/wine-builds/winehq.key -O- | apt-key add -
  echo "deb https://dl.winehq.org/wine-builds/$1 $VERSION_CODENAME main" >/etc/apt/sources.list.d/winehq.list
}

set_wine_version_preference() {
  if [ "${WINEVERSION}" != "latest" ]; then
    {
      echo "Package: *wine* *wine*:i386"
      echo "Pin: version $WINEVERSION~*"
      echo "Pin-Priority: 1001"
    } >/etc/apt/preferences.d/winehq.pref
  fi
}

install_wine() {
  apt-get update
  apt-get install -y --install-recommends winehq-staging

  wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks
  chmod +rx /usr/bin/winetricks

  snippet="export WINEHOME=\"$_REMOTE_USER_HOME\"
export WINEPREFIX=\"\$WINEHOME/.wine32\"
export WINEARCH=win32
export WINEDEBUG=-all"

  update_rc_file "$_REMOTE_USER_HOME/.zshenv" "${snippet}"
  update_rc_file "$_REMOTE_USER_HOME/.profile" "${snippet}"
  update_rc_file "$_REMOTE_USER_HOME/.bashrc" "${snippet}"

  su -l $_REMOTE_USER <<EOF
    mkdir -p "\$WINEPREFIX"
    wine wineboot --init
    mkdir -p "$COREFONTS_CACHE_DIR"
    for filename in ${COREFONTS_FILES[@]}; do
      wget -nv -P "$COREFONTS_CACHE_DIR" "$COREFONTS_BASE_URL\$filename"
    done
    winetricks corefonts
EOF

  # Cleanup
  apt purge --auto-remove -y
  apt autoremove --purge -y
  rm -rf /var/lib/apt/lists/*
}

. /etc/os-release

if [ "${ID}" = "ubuntu" ]; then
  install_ubuntu() {
    export DEBIAN_FRONTEND=noninteractive
    dpkg --add-architecture i386
    apt-get update
    apt-get install -y apt-transport-https ca-certificates telnet cabextract gnupg2 wget
    add_wine_repo "ubuntu"
    set_wine_version_preference
    install_wine
  }
  install_ubuntu
elif [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
  install_debian() {
    export DEBIAN_FRONTEND=noninteractive
    dpkg --add-architecture i386
    apt-get update
    apt-get install -y apt-transport-https ca-certificates telnet cabextract gnupg2 wget
    add_wine_repo "debian"
    set_wine_version_preference
    install_wine
  }
  install_debian
else
  echo "Linux distro ${ID} not supported."
  exit 1
fi
