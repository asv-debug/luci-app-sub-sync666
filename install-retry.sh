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

i=1
while [ "$i" -le "$TRIES" ]; do
  URL="$BASE/install.sh?v=$(date +%s)-$i"
  echo "--- install download try $i from $BASE ---"
  rm -f "$TMP"

  wget -q -O "$TMP" "$URL" 2>/dev/null || uclient-fetch -q -O "$TMP" "$URL" 2>/dev/null || true

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
