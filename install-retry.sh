#!/bin/sh
# SUBSYNC_INSTALL_RETRY_ACCEPT_ANY_PUBLIC_BUILD_V450
set -u

REPO_OWNER="${REPO_OWNER:-kzolotarev95}"
REPO_NAME="${REPO_NAME:-luci-app-sub-sync666}"
REPO_REF="${REPO_REF:-main}"
BASE="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_REF"
TMP="/tmp/subsync-install-current.sh"
TRIES=10

echo "========================================="
echo " Podcop Sub v666 retry installer v450"
echo "========================================="

fetch_to() {
  dst="$1"
  url="$2"

  if command -v wget >/dev/null 2>&1; then
    wget -q -T 30 -O "$dst" "$url" 2>/dev/null && return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --connect-timeout 15 --max-time 60 "$url" -o "$dst" 2>/dev/null && return 0
  fi

  if command -v uclient-fetch >/dev/null 2>&1; then
    uclient-fetch -q -T 30 -O "$dst" "$url" 2>/dev/null && return 0
  fi

  return 1
}

i=1
while [ "$i" -le "$TRIES" ]; do
  URL="$BASE/install.sh?v=$(date +%s)-$i"
  echo "--- install download try $i from $BASE ---"
  rm -f "$TMP"

  fetch_to "$TMP" "$URL" || true

  if [ -s "$TMP" ] && grep -q 'SUBSYNC_PUBLIC_BUILD_V[0-9]' "$TMP" && sh -n "$TMP"; then
    echo "OK: install.sh public build downloaded and verified"
    sh "$TMP"
    exit $?
  fi

  echo "WARN: downloaded install.sh is not verified public build"
  sleep 3
  i=$((i + 1))
done

echo "ERROR: cannot download verified install.sh public build"
exit 1
