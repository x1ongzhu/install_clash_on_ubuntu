#!/bin/bash

identify_the_operating_system_and_architecture() {
  if [[ "$(uname)" == 'Linux' || "$(uname)" == 'Darwin' ]]; then
    case "$(uname -m)" in
      'amd64' | 'x86_64')
        MACHINE='amd64'
        ;;
      'armv5tel')
        MACHINE='armv5'
        ;;
      'armv6l')
        MACHINE='armv6'
        ;;
      'armv7' | 'armv7l')
        MACHINE='armv7'
        ;;
      'armv8' | 'aarch64')
        MACHINE='armv8'
        ;;
      'mips')
        MACHINE='mips'
        ;;
      'mipsle')
        MACHINE='mipsle'
        ;;
      'mips64')
        MACHINE='mips64'
        ;;
      'mips64le')
        MACHINE='mips64le'
        ;;
      *)
        echo "error: The architecture is not supported."
        exit 1
        ;;
    esac
  else
    echo "error: This operating system is not supported."
    exit 1
  fi
}

version_number() {
  case "$1" in
    'v'*)
      echo "$1"
      ;;
    *)
      echo "v$1"
      ;;
  esac
}

get_version(){
  TMP_FILE="$(mktemp)"
  if ! curl -x "${PROXY}" -sS -H "Accept: application/vnd.github.v3+json" -o "$TMP_FILE" 'https://api.github.com/repos/Dreamacro/clash/releases/latest'; then
    "rm" "$TMP_FILE"
    echo 'error: Failed to get release list, please check your network.'
    exit 1
  fi
  RELEASE_LATEST="$(sed 'y/,/\n/' "$TMP_FILE" | grep 'tag_name' | awk -F '"' '{print $4}')"
  "rm" "$TMP_FILE"
  RELEASE_VERSION="$(version_number "$RELEASE_LATEST")"
}

SYSTEM="$(uname | tr '[:upper:]' '[:lower:]')"
identify_the_operating_system_and_architecture
get_version
DOWNLOAD_LINK="https://github.com/Dreamacro/clash/releases/download/$RELEASE_VERSION/clash-$SYSTEM-$MACHINE-$RELEASE_LATEST.gz"
TMP_DIRECTORY="$(mktemp -d)"
ZIP_FILE="${TMP_DIRECTORY}/clash-$SYSTEM-$MACHINE-$RELEASE_LATEST.gz"
echo "Downloading clash archive: $DOWNLOAD_LINK to: $ZIP_FILE"
if ! curl -x "${PROXY}" -R -H 'Cache-Control: no-cache' -L -o "$ZIP_FILE" "$DOWNLOAD_LINK"; then
echo 'error: Download failed! Please check your network or try again.'
return 1
fi
sudo gzip -c -d "$ZIP_FILE" > /usr/bin/clash
sudo chmod +x /usr/bin/clash
sudo cp -rf clash /etc/clash
sudo cp /etc/clash/config_example.yaml /etc/clash/config.yaml
sudo cp clash.service /etc/systemd/system/clash.service
