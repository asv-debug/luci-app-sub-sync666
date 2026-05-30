#!/bin/sh
# SUBSYNC_PUBLIC_UNINSTALL_V268
# PODCOP_SUB_V666_PUBLIC_UNINSTALL_CLEAN_V221
set -u

echo "========================================="
echo "  Podcop Sub v666 — public uninstall v268"
echo "========================================="
echo "Backup: disabled for public/friend uninstall"

echo "=== restore Podkop route ==="
mkdir -p /usr/share/luci/menu.d
cat > /usr/share/luci/menu.d/luci-app-podkop.json <<'MENU'
{
  "admin/services/podkop": {
    "title": "Podkop",
    "order": 60,
    "action": {
      "type": "view",
      "path": "podkop/podkop"
    },
    "depends": {
      "acl": [ "luci-app-podkop" ]
    }
  }
}
MENU

echo "=== restore Podkop xHTTP patch if helper exists ==="
if [ -x /usr/bin/podcop-sub-v666-xhttp-patch ]; then
  /usr/bin/podcop-sub-v666-xhttp-patch restore || true
fi

echo "=== remove public module files ==="
rm -rf /www/luci-static/resources/view/sub_sync 2>/dev/null || true
rm -f /usr/share/rpcd/acl.d/luci-app-sub-sync.json 2>/dev/null || true
rm -f /usr/bin/sub-sync* /usr/bin/podcop-sub-v666-xhttp-patch 2>/dev/null || true
rm -f /usr/bin/sub-sync-public-ui-patch /usr/bin/sub-sync-public-ui-patch.disabled-v* 2>/dev/null || true

echo "=== clear LuCI cache ==="
rm -rf /tmp/luci-modulecache/* /tmp/luci-indexcache* /tmp/luci-sessions/* 2>/dev/null || true
/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true
/etc/init.d/podkop restart >/dev/null 2>&1 || true

echo "Podcop Sub v666 public uninstall v268 complete"
# SUBSYNC_UNINSTALL_THEME_CLEANUP_V268_BEGIN
echo "=== uninstall ProtoByZKS95/proton2025 theme ==="

subsync_remove_proton2025_local_v268() {
  echo "=== local fallback remove ProtoByZKS95/proton2025 theme ==="
  rm -rf /www/luci-static/proton2025 2>/dev/null || true
  rm -f /usr/share/ucode/luci/template/themes/proton2025* 2>/dev/null || true
  rm -rf /usr/share/ucode/luci/template/themes/proton2025 2>/dev/null || true
  rm -f /usr/libexec/rpcd/proton2025* /usr/bin/proton2025* 2>/dev/null || true
  uci delete luci.themes.ProtoByZKS95 2>/dev/null || true
  if [ "$(uci get luci.main.mediaurlbase 2>/dev/null || true)" = "/luci-static/proton2025" ]; then
    uci set luci.main.mediaurlbase="/luci-static/bootstrap" 2>/dev/null || true
  fi
  uci commit luci 2>/dev/null || true
  rm -rf /tmp/luci-modulecache /tmp/luci-modulecache/* /tmp/luci-indexcache /tmp/luci-indexcache* /tmp/luci-sessions /tmp/luci-sessions/* 2>/dev/null || true
  echo "OK: local theme fallback cleanup done"
}

THEME_UNINSTALL_URL="${THEME_UNINSTALL_URL:-https://raw.githubusercontent.com/kzolotarev95/luci-theme-protobyzks95/main/uninstall.sh}"

if wget -O /tmp/protobyzks95-uninstall.sh "$THEME_UNINSTALL_URL?v=$(date +%s)"; then
  if sh -n /tmp/protobyzks95-uninstall.sh; then
    sh /tmp/protobyzks95-uninstall.sh || subsync_remove_proton2025_local_v268
  else
    echo "WARN: theme uninstall syntax failed"
    subsync_remove_proton2025_local_v268
  fi
else
  echo "WARN: theme uninstall download failed"
  subsync_remove_proton2025_local_v268
fi

rm -f /tmp/protobyzks95-uninstall.sh 2>/dev/null || true
# SUBSYNC_UNINSTALL_THEME_CLEANUP_V268_END
