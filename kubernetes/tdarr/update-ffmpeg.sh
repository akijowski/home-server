#! /bin/bash

#
# This script updates the ffmpeg used to the latest from jellyfin
# Inspired by: https://github.com/HaveAGitGat/Tdarr/issues/1101
#

set -eou pipefail

LOG_PREFIX="[update-ffmpeg]"
JELLYFIN_FFMPEG_LATEST=""
JELLYFIN_GITHUB_REPO="jellyfin/jellyfin-ffmpeg"

function logf() {
    echo "$LOG_PREFIX $1"
}

function ensure_required_apps() {
    if [ -z "$(command -v jq)" ]; then
        logf "jq is required but not installed. Exiting."
        exit 1
    fi
    if [ -z "$(command -v wget)" ]; then
        logf "wget is required by not installed. Exiting."
        exit 1
    fi
    if [-z "$(command -v sed)" ]; then
        logf "sed is required by not installed. Exiting."
        exit 1
    fi
}

function get_latest_tag() {
    logf "getting latest tag"
    JELLYFIN_FFMPEG_LATEST=$(wget -q -O- "https://api.github.com/repos/${JELLYFIN_GITHUB_REPO}/releases/latest" | jq -r .tag_name)
    logf "found $JELLYFIN_FFMPEG_LATEST"
}

# TODO: refactor
function download_arm64() {
    logf "downloading $JELLYFIN_FFMPEG_LATEST for arm64"
    nonsemver=$(echo "$JELLYFIN_FFMPEG_LATEST" | sed -e 's/v//')
    deb_file="jellyfin-ffmpeg7_$nonsemver-jammy_arm64.deb"
    dl_url="https://github.com/$JELLYFIN_GITHUB_REPO/releases/download/$JELLYFIN_FFMPEG_LATEST/$deb_file"
    logf "downloading: $dl_url"
    wget "dl_url"
    apt install -y "./$deb_file"
    logf "cleaning up $deb_file"
    rm -rf "./$deb_file"
}

# TODO: refactor
function download_amd64() {
    logf "downloading $JELLYFIN_FFMPEG_LATEST for amd64"
    nonsemver=$(echo "$JELLYFIN_FFMPEG_LATEST" | sed -e 's/v//')
    deb_file="jellyfin-ffmpeg7_$nonsemver-jammy_amd64.deb"
    dl_url="https://github.com/$JELLYFIN_GITHUB_REPO/releases/download/$JELLYFIN_FFMPEG_LATEST/$deb_file"
    logf "downloading: $dl_url"
    wget "dl_url"
    apt install -y "./$deb_file"
    logf "cleaning up $deb_file"
    rm -rf "./$deb_file"
}

# TODO: refactor
function download_latest() {
    if [ uname -m | grep -q aarch64 ]; then
        download_arm64
    else
        download_amd64
    fi
}

function link_binaries() {
    logf "setting symlinks"
    jf="/usr/lib/jellyfin-ffmpeg/ffmpeg"
    ln -sv "$jf" "/usr/local/bin/ffmpeg"
    ln -sv "$jf" "/usr/local/bin/tdarr-ffmpeg"
}

function main() {
    ensure_required_apps
    get_latest_tag
    download_latest
    link_binaries
}

main "$@"
