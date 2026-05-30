#!/bin/sh
# SUBSYNC_PUBLIC_BUILD_V271
# SUBSYNC_SKIP_THEME_IF_PRESENT_V260_BEGIN
if [ -d /www/luci-static/proton2025 ] && uci show luci 2>/dev/null | grep -q "ProtoByZKS95"; then
  export SUBSYNC_SKIP_PROTOBYZKS95_THEME=1
fi
# SUBSYNC_SKIP_THEME_IF_PRESENT_V260_END
# PODCOP_SUB_V666_PUBLIC_INSTALL_CLEAN_V221
set -u

REPO_SLUG="${SUBSYNC_REPO:-kzolotarev95/luci-app-sub-sync666}"
BRANCH="${SUBSYNC_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO_SLUG}/${BRANCH}"

echo "========================================="
echo "  Podcop Sub v666 — public install v271"
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
echo "Podcop Sub v666 public install v271 complete"
echo "Open: Services -> Podkop"
echo "Re-login LuCI after install"
echo "========================================="
# SUBSYNC_INSTALL_VERSION_FILES_V271_BEGIN
echo "========================================="
echo " Podcop Sub v666 OTA v271 clean install"
echo "========================================="

SUBSYNC_RAW_BASE="${SUBSYNC_RAW_BASE:-${RAW_BASE:-https://raw.githubusercontent.com/kzolotarev95/luci-app-sub-sync666/main}}"
THEME_RAW="https://raw.githubusercontent.com/kzolotarev95/luci-theme-protobyzks95/main/install.sh"
DST="/www/luci-static/resources/view/sub_sync"
SRC_JS="$DST/sub_sync.js"
THEME_OK=0

subsync_theme_install_v271() {
  i=1
  while [ "$i" -le 5 ]; do
    echo "=== theme install try $i/5 ==="
    if wget -O /tmp/protobyzks95-install.sh "$THEME_RAW?v=$(date +%s)-$i"; then
      if sh -n /tmp/protobyzks95-install.sh; then
        if sh /tmp/protobyzks95-install.sh; then
          if [ -d /www/luci-static/proton2025 ]; then
            uci set luci.main.mediaurlbase='/luci-static/proton2025' 2>/dev/null || true
            uci commit luci 2>/dev/null || true
            echo "OK: theme installed and active: $(uci get luci.main.mediaurlbase 2>/dev/null || true)"
            return 0
          fi
        fi
      else
        echo "WARN: downloaded theme installer syntax failed"
      fi
    fi
    echo "WARN: theme install try $i failed"
    i=$((i + 1))
    sleep 4
  done

  if [ -d /www/luci-static/proton2025 ]; then
    uci set luci.main.mediaurlbase='/luci-static/proton2025' 2>/dev/null || true
    uci commit luci 2>/dev/null || true
    echo "OK: theme already exists and active: $(uci get luci.main.mediaurlbase 2>/dev/null || true)"
    return 0
  fi

  echo "WARN_THEME_FAILED: module will remain installed, but proton2025 theme was not installed"
  return 1
}

echo "[1/15] prepare folders"
mkdir -p /etc/sub-sync /usr/bin /etc/init.d /usr/share/luci/menu.d /usr/share/rpcd/acl.d "$DST"

echo "[2/15] install persistent guard helper before theme"
if wget -qO /usr/bin/podcop-sub-v666-guard "$SUBSYNC_RAW_BASE/usr/bin/podcop-sub-v666-guard?v=$(date +%s)"; then
  chmod 755 /usr/bin/podcop-sub-v666-guard
else
  echo "ERROR: failed to download guard helper before theme"
  exit 1
fi

echo "[3/15] install guard init service before theme"
if wget -qO /etc/init.d/podcop-sub-v666-guard "$SUBSYNC_RAW_BASE/etc/init.d/podcop-sub-v666-guard?v=$(date +%s)"; then
  chmod 755 /etc/init.d/podcop-sub-v666-guard
  /etc/init.d/podcop-sub-v666-guard enable >/dev/null 2>&1 || true
else
  echo "WARN: guard init download failed before theme"
fi

echo "[4/15] install cron guard"
touch /etc/crontabs/root
grep -q '/usr/bin/podcop-sub-v666-guard' /etc/crontabs/root 2>/dev/null || \
  echo '*/5 * * * * /usr/bin/podcop-sub-v666-guard >/tmp/podcop-sub-v666-guard.log 2>&1' >> /etc/crontabs/root
/etc/init.d/cron restart >/dev/null 2>&1 || true

echo "[5/15] install updater helper before theme"
wget -qO /usr/bin/sub-sync-module-update "$SUBSYNC_RAW_BASE/usr/bin/sub-sync-module-update?v=$(date +%s)" && chmod 755 /usr/bin/sub-sync-module-update || echo "WARN: updater download failed before theme"

echo "[6/15] install ProtoByZKS95/proton2025 theme with retries"
if subsync_theme_install_v271; then
  THEME_OK=1
else
  THEME_OK=0
fi

echo "[7/15] verify module JS from base install"
if [ ! -s "$SRC_JS" ]; then
  echo "ERROR: module JS missing after base install: $SRC_JS"
  exit 1
fi

echo "[8/15] verify ACL/menu exist"
[ -s /usr/share/rpcd/acl.d/luci-app-sub-sync.json ] || { echo "ERROR: ACL missing"; exit 1; }
[ -s /usr/share/luci/menu.d/luci-app-sub-sync.json ] || { echo "ERROR: menu missing"; exit 1; }

echo "[9/15] verify UI markers"
grep -q 'SUBSYNC_DIRECT_REMOVE_MANUAL_HIDE_LOAD_V266B' "$SRC_JS" || { echo "ERROR: v266b direct UI marker missing"; exit 1; }
grep -q 'SUBSYNC_HIDE_UPDATE_CHECK_BUTTON_V269B' "$SRC_JS" || { echo "ERROR: update check hide marker missing"; exit 1; }
grep -q 'SUBSYNC_UI_UPDATE_LIVE_TIMER_V263' "$SRC_JS" || { echo "ERROR: v263 timer marker missing"; exit 1; }
grep -q 'SUBSYNC_DONATE_COPY_BUTTON_V258' "$SRC_JS" || { echo "ERROR: donate copy marker missing"; exit 1; }
if grep -q 'Мануал: как пользоваться модулем' "$SRC_JS"; then
  echo "ERROR: manual text still exists in local JS"
  exit 1
fi
grep -q 'display:none!important;visibility:hidden!important;padding:2px 12px' "$SRC_JS" || { echo "ERROR: load button hidden style missing"; exit 1; }

echo "[10/15] install JS aliases from local tested JS"
for v in 208 211 212 221 238 252 253 254 255 256 258 259 260 261 262 263 264 265 266 267 268 269 270 271; do
  cp -f "$SRC_JS" "$DST/sub_sync_v${v}.js"
done
chmod 755 "$DST"
chmod 644 "$DST"/*.js 2>/dev/null || true

echo "[11/15] force clean menu"
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

echo "[12/15] run guard now"
if [ -x /usr/bin/podcop-sub-v666-guard ]; then
  /usr/bin/podcop-sub-v666-guard || echo "WARN: guard returned non-zero"
else
  echo "WARN: guard helper missing"
fi

echo "[13/15] write local version"
echo "271" > /etc/sub-sync/module-build
echo "v271" > /etc/sub-sync/module-version

echo "[14/15] clear LuCI cache"
rm -rf /tmp/luci-modulecache /tmp/luci-modulecache/* /tmp/luci-indexcache /tmp/luci-indexcache* /tmp/luci-sessions /tmp/luci-sessions/* 2>/dev/null || true
find /tmp -maxdepth 1 -type d -name 'luci-*cache*' -exec rm -rf {} + 2>/dev/null || true
find /tmp -maxdepth 1 -type f -name 'luci-*cache*' -delete 2>/dev/null || true
sync

echo "[15/15] final install verification"
ls -l "$SRC_JS" /usr/share/luci/menu.d/luci-app-sub-sync.json /usr/share/rpcd/acl.d/luci-app-sub-sync.json 2>/dev/null || true
uci get luci.main.mediaurlbase 2>/dev/null || true
grep -RsnE 'sub_sync|Подписки|Мониторинг' /usr/share/luci/menu.d/*.json 2>/dev/null || true
grep -n 'podcop-sub-v666-guard' /etc/crontabs/root 2>/dev/null || true

nohup sh -c 'sleep 3; /etc/init.d/rpcd restart >/dev/null 2>&1 || true; /etc/init.d/uhttpd restart >/dev/null 2>&1 || true' >/tmp/subsync-v271-delayed-restart.log 2>&1 &

rm -f /tmp/protobyzks95-install.sh 2>/dev/null || true
logger -t sub-sync "Podcop Sub v666 public build v271 installed clean install/uninstall" 2>/dev/null || true

echo "DONE_MODULE_OK: Podcop Sub v666 v271 module installed."
if [ "$THEME_OK" = "1" ]; then
  echo "DONE_THEME_OK: ProtoByZKS95/proton2025 theme installed/active."
else
  echo "WARN_THEME_FAILED: Module installed, but theme download/install failed. Re-run install later or install theme separately."
fi
echo "DONE: install.sh finished rc=0"
# SUBSYNC_INSTALL_VERSION_FILES_V271_END
