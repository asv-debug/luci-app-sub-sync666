#!/bin/sh

echo ""
echo "========================================="
echo "  Podkop Sub Sync — integrated uninstall"
echo "========================================="
echo ""

PODKOP_MENU="/usr/share/luci/menu.d/luci-app-podkop.json"
PODKOP_BAK="/usr/share/luci/menu.d/luci-app-podkop.json.bak.subsync"

BACKUP="/root/luci-app-sub-sync-before-uninstall-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "→ Бэкап перед удалением..."
tar -czf "$BACKUP" -C / \
  usr/share/luci/menu.d/luci-app-podkop.json \
  usr/share/luci/menu.d/luci-app-podkop.json.bak.subsync \
  usr/share/luci/menu.d/luci-app-sub-sync.json \
  usr/share/rpcd/acl.d/luci-app-sub-sync.json \
  www/luci-static/resources/view/sub_sync \
  usr/bin/sub-sync \
  etc/sub-sync \
  2>/dev/null || true
echo "  ✓ Бэкап: $BACKUP"

echo "→ Восстановление родного меню Podkop..."
if [ -f "$PODKOP_BAK" ]; then
    cp -f "$PODKOP_BAK" "$PODKOP_MENU"
    chmod 644 "$PODKOP_MENU"
    rm -f "$PODKOP_BAK"
    echo "  ✓ Меню Podkop восстановлено из бэкапа"
else
    echo "  ! Бэкап меню не найден, ставлю безопасный стандартный route podkop/podkop"
    cat > "$PODKOP_MENU" <<'MENUEOF'
{
    "admin/services/podkop": {
        "title": "Podkop",
        "order": 42,
        "action": {
            "type": "view",
            "path": "podkop/podkop"
        },
        "depends": {
            "acl": [ "luci-app-podkop" ],
            "uci": { "podkop": true }
        }
    }
}
MENUEOF
    chmod 644 "$PODKOP_MENU"
fi

echo "→ Удаление cron-задачи..."
sed -i '/\/usr\/bin\/sub-sync/d;/sub-sync/d;/subsync/d;/sub_sync/d' /etc/crontabs/root 2>/dev/null || true
/etc/init.d/cron restart 2>/dev/null || true

echo "→ Удаление файлов Sub Sync..."
rm -f /usr/share/luci/menu.d/luci-app-sub-sync.json
rm -f /usr/share/rpcd/acl.d/luci-app-sub-sync.json
rm -rf /www/luci-static/resources/view/sub_sync
rm -f /usr/bin/sub-sync
rm -rf /etc/sub-sync
rm -f /tmp/sub-sync-status /tmp/sub-sync-response /tmp/sub-sync-decoded
rm -rf /tmp/sub-sync* /tmp/subsync-* /tmp/luci-app-sub-sync* 2>/dev/null || true

echo "→ Очистка LuCI кэша..."
rm -rf /tmp/luci-modulecache/* /tmp/luci-indexcache* /tmp/luci-sessions/* 2>/dev/null || true
touch /usr/lib/opkg/status 2>/dev/null || touch /lib/apk/db/installed 2>/dev/null || true

echo "→ Перезапуск LuCI..."
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd restart 2>/dev/null || true

echo "→ Проверка Podkop route..."
grep -n '"path"' "$PODKOP_MENU" 2>/dev/null || true

echo ""
echo "========================================="
echo "  Sub Sync удалён, Podkop восстановлен"
echo "========================================="
echo ""
echo "  Бэкап:"
echo "  $BACKUP"
echo ""
echo "  Откат:"
echo "  tar -xzf $BACKUP -C /"
echo ""
echo "  Обнови страницу: Ctrl+F5"
echo ""
