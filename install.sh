#!/bin/sh
# SUBSYNC_PUBLIC_BUILD_V263
# SUBSYNC_PUBLIC_BUILD_V261
# SUBSYNC_SKIP_THEME_IF_PRESENT_V260_BEGIN
if [ -d /www/luci-static/proton2025 ] && uci show luci 2>/dev/null | grep -q "ProtoByZKS95"; then
  export SUBSYNC_SKIP_PROTOBYZKS95_THEME=1
fi
# SUBSYNC_SKIP_THEME_IF_PRESENT_V260_END
# SUBSYNC_PUBLIC_BUILD_V260
# SUBSYNC_PUBLIC_BUILD_V259
# SUBSYNC_PUBLIC_BUILD_V258
# SUBSYNC_PUBLIC_BUILD_V256
# SUBSYNC_PUBLIC_BUILD_V255
# SUBSYNC_PUBLIC_BUILD_V254
# SUBSYNC_PUBLIC_BUILD_V253
# SUBSYNC_PUBLIC_BUILD_V252
# SUBSYNC_PUBLIC_BUILD_V238
# PODCOP_SUB_V666_PUBLIC_INSTALL_CLEAN_V221
set -u

REPO_SLUG="${SUBSYNC_REPO:-kzolotarev95/luci-app-sub-sync666}"
BRANCH="${SUBSYNC_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO_SLUG}/${BRANCH}"

echo "========================================="
echo "  Podcop Sub v666 — public install v263"
echo "========================================="
echo "Backup: disabled for public/friend install"

fetch_file() {
  src="$1"
  dst="$2"
  mode="${3:-755}"
  mkdir -p "$(dirname "$dst")"
  if wget -qO "$dst" "$RAW/$src?v=$(date +%s)"; then
    chmod "$mode" "$dst" 2>/dev/null || true
    echo "OK: $dst"
  else
    echo "WARN: failed to download $src"
    return 1
  fi
}

echo "=== install UI ==="
fetch_file "htdocs/luci-static/resources/view/sub_sync/sub_sync.js" "/www/luci-static/resources/view/sub_sync/sub_sync.js" 644
fetch_file "htdocs/luci-static/resources/view/sub_sync/sub_sync_v221.js" "/www/luci-static/resources/view/sub_sync/sub_sync_v221.js" 644

echo "=== install ACL ==="
fetch_file "usr/share/rpcd/acl.d/luci-app-sub-sync.json" "/usr/share/rpcd/acl.d/luci-app-sub-sync.json" 644

echo "=== install helpers ==="
for f in \
  podcop-sub-v666-xhttp-patch \
  sub-sync \
  sub-sync.real \
  sub-sync.v51base \
  sub-sync.v164manualbase \
  sub-sync-autoadd \
  sub-sync-donaters \
  sub-sync-happ-json-hy2-import \
  sub-sync-hy2-manager \
  sub-sync-hy2-probe \
  sub-sync-hy2-urltest \
  sub-sync-manual-import \
  sub-sync-manual-link \
  sub-sync-section \
  sub-sync-singbox-log \
  sub-sync-subs-info \
  sub-sync-system-info \
  sub-sync-urltest \
  sub-sync-xhttp-guard
do
  fetch_file "usr/bin/$f" "/usr/bin/$f" 755 || true
done

echo "=== install public donor state ==="
mkdir -p /etc/sub-sync
fetch_file "etc/sub-sync/donaters.tsv" "/etc/sub-sync/donaters.tsv" 600 || true

echo "=== remove stale old helper files ==="
rm -f /usr/bin/sub-sync-public-ui-patch /usr/bin/sub-sync-public-ui-patch.disabled-v* 2>/dev/null || true
rm -f /usr/bin/*prev* /usr/bin/*before* /usr/bin/*.bak /usr/bin/*real-v* /usr/bin/sub-sync-hy2-ping 2>/dev/null || true

echo "=== integrate into Services -> Podkop ==="
mkdir -p /usr/share/luci/menu.d
cat > /usr/share/luci/menu.d/luci-app-podkop.json <<'MENU'
{
  "admin/services/podkop": {
    "title": "Podkop",
    "order": 42,
    "action": {
      "type": "view",
      "path": "sub_sync/sub_sync_v221"
    },
    "depends": {
      "acl": [ "luci-app-podkop", "luci-app-sub-sync" ],
      "uci": { "podkop": true }
    }
  }
}
MENU

rm -f /usr/share/luci/menu.d/luci-app-sub-sync.json 2>/dev/null || true

echo "=== apply Podkop xHTTP patch ==="
if [ -x /usr/bin/podcop-sub-v666-xhttp-patch ]; then
  /usr/bin/podcop-sub-v666-xhttp-patch apply || true
fi

echo "=== clear LuCI cache ==="
rm -rf /tmp/luci-modulecache/* /tmp/luci-indexcache* /tmp/luci-sessions/* 2>/dev/null || true
: # V260_DELAYED_RESTART old immediate rpcd restart disabled
: # V260_DELAYED_RESTART old immediate uhttpd restart disabled
/etc/init.d/podkop restart >/dev/null 2>&1 || true

echo "========================================="
echo "Podcop Sub v666 public install v263 complete"
echo "Open: Services -> Podkop"
echo "Re-login LuCI after install"
echo "========================================="
# SUBSYNC_INSTALL_VERSION_FILES_V263_BEGIN
echo "========================================="
echo " Podcop Sub v666 OTA v263 real report"
echo "========================================="

SUBSYNC_RAW_BASE="${SUBSYNC_RAW_BASE:-${RAW_BASE:-https://raw.githubusercontent.com/kzolotarev95/luci-app-sub-sync666/main}}"
THEME_RAW="https://raw.githubusercontent.com/kzolotarev95/luci-theme-protobyzks95/main/install.sh"
DST="/www/luci-static/resources/view/sub_sync"
TMP_JS="/tmp/sub-sync-v263-$RANDOM.js"

echo "[1/12] install ProtoByZKS95 theme"
if wget -qO /tmp/protobyzks95-install.sh "$THEME_RAW?v=$(date +%s)"; then
  if sh -n /tmp/protobyzks95-install.sh; then
    sh /tmp/protobyzks95-install.sh || echo "WARN: theme installer returned non-zero"
  else
    echo "WARN: theme install.sh syntax failed"
  fi
else
  echo "WARN: theme installer download failed"
fi

if [ -d /www/luci-static/proton2025 ]; then
  uci set luci.main.mediaurlbase='/luci-static/proton2025' 2>/dev/null || true
  uci commit luci 2>/dev/null || true
fi

echo "[2/12] prepare folders"
mkdir -p /etc/sub-sync /usr/bin /usr/share/rpcd/acl.d /usr/share/luci/menu.d "$DST"

echo "[3/12] restore independent Podkop Sub menu"
cat > /usr/share/luci/menu.d/luci-app-sub-sync.json <<'MENU'
{
  "admin/services/podkop/sub_sync": {
    "title": "Подписки / Мониторинг",
    "order": 95,
    "action": {
      "type": "view",
      "path": "sub_sync/sub_sync"
    },
    "depends": {
      "acl": [ "luci-app-sub-sync" ]
    }
  }
}
MENU

echo "[4/12] download new module JS"
if ! wget -qO "$TMP_JS" "$SUBSYNC_RAW_BASE/htdocs/luci-static/resources/view/sub_sync/sub_sync.js?v=$(date +%s)"; then
  echo "ERROR: failed to download sub_sync.js"
  exit 1
fi

echo "[5/12] verify JS markers"
grep -q 'SUBSYNC_DONATE_COPY_BUTTON_V258' "$TMP_JS" || { echo "ERROR: donate copy marker missing"; exit 1; }
grep -q 'SUBSYNC_UPDATE_CHECK_TEXT_V261' "$TMP_JS" || { echo "ERROR: v261 check marker missing"; exit 1; }
grep -q 'SUBSYNC_UI_UPDATE_LIVE_TIMER_V263' "$TMP_JS" || { echo "ERROR: v263 timer marker missing"; exit 1; }

echo "[6/12] install JS safely without deleting active aliases"
cp -f "$TMP_JS" "$DST/sub_sync.js"
for v in 208 211 212 221 238 252 253 254 255 256 258 259 260 261 262 263; do
  cp -f "$TMP_JS" "$DST/sub_sync_v${v}.js"
done
chmod 755 "$DST"
chmod 644 "$DST"/*.js 2>/dev/null || true

echo "[7/12] remove only stale temp/live files"
rm -f "$DST"/sub_sync_live_*.js "$DST"/sub_sync_tmp_*.js "$DST"/*.bak "$DST"/*.old "$DST"/*.tmp 2>/dev/null || true

echo "[8/12] install updater and ACL"
wget -qO /usr/bin/sub-sync-module-update "$SUBSYNC_RAW_BASE/usr/bin/sub-sync-module-update?v=$(date +%s)" && chmod 755 /usr/bin/sub-sync-module-update || echo "WARN: updater download failed"
wget -qO /usr/share/rpcd/acl.d/luci-app-sub-sync.json "$SUBSYNC_RAW_BASE/usr/share/rpcd/acl.d/luci-app-sub-sync.json?v=$(date +%s)" || echo "WARN: ACL download failed"

echo "[9/12] apply Podkop xHTTP patch"
if [ -x /usr/bin/podcop-sub-v666-xhttp-patch ]; then
  /usr/bin/podcop-sub-v666-xhttp-patch || echo "WARN: xHTTP patch returned non-zero"
fi

echo "[10/12] write local version"
echo "263" > /etc/sub-sync/module-build
echo "v263" > /etc/sub-sync/module-version

echo "[11/12] clear LuCI cache files"
rm -rf /tmp/luci-modulecache /tmp/luci-modulecache/* /tmp/luci-indexcache /tmp/luci-indexcache* /tmp/luci-sessions /tmp/luci-sessions/* 2>/dev/null || true
find /tmp -maxdepth 1 -type d -name 'luci-*cache*' -exec rm -rf {} + 2>/dev/null || true
find /tmp -maxdepth 1 -type f -name 'luci-*cache*' -delete 2>/dev/null || true
sync

echo "[12/12] schedule LuCI service restart after report"
nohup sh -c 'sleep 3; rm -rf /tmp/luci-modulecache /tmp/luci-modulecache/* /tmp/luci-indexcache /tmp/luci-indexcache* /tmp/luci-sessions /tmp/luci-sessions/* 2>/dev/null || true; /etc/init.d/rpcd restart >/dev/null 2>&1 || true; /etc/init.d/uhttpd restart >/dev/null 2>&1 || true' >/tmp/subsync-v263-delayed-restart.log 2>&1 &

rm -f "$TMP_JS" /tmp/protobyzks95-install.sh 2>/dev/null || true
logger -t sub-sync "Podcop Sub v666 public build v263 installed" 2>/dev/null || true

echo "DONE: install.sh finished rc=0"
echo "DONE: Podcop Sub v666 v263 installed. LuCI will restart in a few seconds."
# SUBSYNC_INSTALL_VERSION_FILES_V263_END
