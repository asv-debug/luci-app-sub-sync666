#!/bin/sh
set -u

REPO_OWNER="${REPO_OWNER:-kzolotarev95}"
REPO_NAME="${REPO_NAME:-luci-app-sub-sync666}"
REPO_REF="${REPO_REF:-main}"
BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_REF"
TMP="/tmp/subsync-install-v359.sh"

echo "========================================="
echo " Podcop Sub v666 retry installer v359"
echo "========================================="

i=1
while [ "$i" -le 10 ]; do
  echo "--- install download try $i from $BASE_URL ---"
  wget -O "$TMP" "$BASE_URL/install.sh?v=$(date +%s)-$i" || true

  if [ -s "$TMP" ] && grep -q 'SUBSYNC_PUBLIC_BUILD_V340' "$TMP" && sh -n "$TMP"; then
    echo "OK: install.sh v359 downloaded and verified"
    sh "$TMP"
    exit $?
  fi

  echo "WARN: downloaded install.sh is not verified v359"
  i=$((i + 1))
  sleep 3
done

echo "ERROR: cannot download verified install.sh v359"
exit 1
